#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=35G
#SBATCH -o vcf_gathering.out

### Written by Valeria Anorve-Garibay

# gather the per-chromosome VCFs into one VCF
# e.g. 'sbatch 09.VCFsGathering.sh'

start=`date +%s`

# paths
base_path=/path/to/IndigenousMXB
vcf_dir=$base_path/VCF_GRCh38
out_path=$vcf_dir/VCF_merged
build=GRCh38

# load modules
module load gatk samtools tabix
module load openjdk/11.0.17_8-nw5ylvi

set -e  # stop script on first error

mkdir -p $out_path

# create list file
> indigenous_mxb_vcf_list
for i in {1..22}; do
    echo "$vcf_dir/indigenous_mxb_raw_${build}.chrom$i.vcf.gz" >> indigenous_mxb_vcf_list
done

echo "Pre-processing indigenous_mxb VCF in ${build}"
# 1. Gather VCFs
echo "Gathering VCFs..."
gatk --java-options "-Xms32G -Xmx32G -XX:ParallelGCThreads=8" GatherVcfs \
    $(awk '{print "--INPUT "$1}' indigenous_mxb_vcf_list) \
    -O $out_path/indigenous_mxb_raw_${build}.vcf.gz

# 2. Index gathered VCF
echo "Indexing gathered VCF..."
gatk --java-options "-Xms32G -Xmx32G -XX:ParallelGCThreads=8" IndexFeatureFile \
    -I $out_path/indigenous_mxb_raw_${build}.vcf.gz

end=`date +%s`
runtime=$((end-start))
echo "Done."
echo "run time: $runtime"
