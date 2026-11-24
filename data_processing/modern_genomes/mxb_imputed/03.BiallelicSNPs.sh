#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=10G

### Written by Valeria Anorve-Garibay

# keep bi-allelic SNPs only (filter out InDels and multiallelic sites)
# 271,420,326 bi-allelic SNPs
# e.g. 'sbatch --array=1-22 03.BiallelicSNPs.sh'

# paths
out_path=/path/to/MXB-imputed/MXB_b151_b38

# load modules
module load bcftools tabix

set -e  # stop script on first error

chrom=${SLURM_ARRAY_TASK_ID}

cd $out_path

input_vcf=renamed/MXB_6k.chr${chrom}.b151.numeric.rnamed.vcf.gz
bcftools view -m2 -M2 -v snps --threads 4 $input_vcf \
    -Oz -o MXB_6k.chr${chrom}.b151.numeric.rnamed.bi_allelic.vcf.gz
tabix -p vcf MXB_6k.chr${chrom}.b151.numeric.rnamed.bi_allelic.vcf.gz

echo "Done."
