#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=35G

### Written by Valeria Anorve-Garibay

# split the final filtered VCF into SNPs and InDels
# e.g. 'sbatch 12.ExtractSNPs_InDels.sh'

# paths
base_path=/path/to/IndigenousMXB
vcf_dir=$base_path/VCF_GRCh38
out_path=$vcf_dir/VCF_merged
build=GRCh38

# load modules
module load gatk

set -e  # stop script on first error

gatk --java-options "-Xms32G -Xmx32G -XX:ParallelGCThreads=8" SelectVariants \
    --select-type-to-include SNP \
    -V $out_path/indigenous_mxb_filtered_${build}_autosomes.vcf.gz \
    --output $out_path/indigenous_mxb_filtered_SNPs_${build}_autosomes.vcf.gz
gatk --java-options "-Xms32G -Xmx32G -XX:ParallelGCThreads=8" SelectVariants \
    --select-type-to-include INDEL \
    -V $out_path/indigenous_mxb_filtered_${build}_autosomes.vcf.gz \
    --output $out_path/indigenous_mxb_filtered_InDel_${build}_autosomes.vcf.gz

echo "Done."
