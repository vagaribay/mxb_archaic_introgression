#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=25G

### Written by Valeria Anorve-Garibay

# rename chromosomes from 1-22 to chr1-chr22 in the raw and filtered VCFs
# e.g. 'sbatch 11.RenameChrVCF.sh'

start=`date +%s`

# paths
base_path=/path/to/IndigenousMXB
vcf_dir=$base_path/VCF_GRCh38
out_path=$vcf_dir/VCF_merged
build=GRCh38

# load modules
module load bcftools tabix

set -e  # stop script on first error

# create rename file
> rename_chrom.txt
for i in {1..22}; do
    echo -e "$i\tchr$i" >> rename_chrom.txt
done

# filtered VCF
bcftools annotate --rename-chrs rename_chrom.txt --threads 8 -Oz \
    -o $out_path/indigenous_mxb_filtered_${build}_autosomes.vcf.gz \
    $out_path/indigenous_mxb_filtered_${build}.vcf.gz
tabix -p vcf $out_path/indigenous_mxb_filtered_${build}_autosomes.vcf.gz
bcftools stats $out_path/indigenous_mxb_filtered_${build}_autosomes.vcf.gz > $out_path/indigenous_mxb_filtered_${build}_autosomes.stats

# raw VCF
bcftools annotate --rename-chrs rename_chrom.txt --threads 8 -Oz \
    -o $out_path/indigenous_mxb_raw_${build}_autosomes.vcf.gz \
    $out_path/indigenous_mxb_raw_${build}.vcf.gz
tabix -p vcf $out_path/indigenous_mxb_raw_${build}_autosomes.vcf.gz

end=`date +%s`
runtime=$((end-start))
echo "Done."
echo "run time: $runtime"
