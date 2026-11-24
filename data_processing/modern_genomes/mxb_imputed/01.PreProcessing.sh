#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=10G

### Written by Valeria Anorve-Garibay

# Pre-processing of the MXB imputed data (6,011 individuals, TOPMed imputation by the data providers)
# 1. rename chromosomes: from N to chrN
# 2. change sample IDs in header
# e.g. 'sbatch --array=1-22 01.PreProcessing.sh'

# paths
raw_path=/path/to/MXB-imputed/raw
out_path=/path/to/MXB-imputed/MXB_b151_b38
# file with MXB sample IDs (column 3: new sample ID, same order as the VCF header)
sample_ids=/path/to/MXB.IDs.txt

# load modules
module load bcftools tabix

set -e  # stop script on first error

chrom=${SLURM_ARRAY_TASK_ID}

mkdir -p $out_path/annot $out_path/renamed
cd $out_path

# 1. Rename chromosomes
echo -e "$chrom\tchr$chrom" > chr${chrom}.rename_chrom.txt
bcftools annotate --rename-chrs chr${chrom}.rename_chrom.txt --threads 8 \
    -Oz -o annot/MXB_6k.chr${chrom}.b151.numeric.vcf.gz \
    $raw_path/MXB_6k.chr${chrom}.b151.numeric.vcf.gz
tabix -p vcf annot/MXB_6k.chr${chrom}.b151.numeric.vcf.gz
bcftools stats --threads 8 annot/MXB_6k.chr${chrom}.b151.numeric.vcf.gz > annot/MXB_6k.chr${chrom}.b151.numeric.stats
rm chr${chrom}.rename_chrom.txt

# 2. Change sample IDs in header
bcftools reheader -s <(cut -f3 $sample_ids) annot/MXB_6k.chr${chrom}.b151.numeric.vcf.gz \
    -o renamed/MXB_6k.chr${chrom}.b151.numeric.rnamed.vcf.gz
tabix -p vcf renamed/MXB_6k.chr${chrom}.b151.numeric.rnamed.vcf.gz

echo "Done."
