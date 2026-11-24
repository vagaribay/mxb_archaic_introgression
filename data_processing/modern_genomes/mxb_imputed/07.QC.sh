#!/bin/bash
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=20G

### Written by Valeria Anorve-Garibay

# QC version of the bi-allelic MXB imputed data (MXB-imputed)
# 1. keep SNPs with R2 > 0.01 (minimac4)
# 2. remove related individuals up to the third degree (from ref. 2) and keep SNPs with MAF > 0.1%
# 3. remove duplicated positions; they are ambiguous multiallelic sites and might be noisy
# 4. fix sample ID MXB_40321(40331) to MXB_40321_40331
# final: 5,833 individuals and 17,176,220 SNPs
# e.g. 'sbatch --array=1-22 07.QC.sh'

# paths
in_path=/path/to/MXB-imputed/MXB_b151_b38
qc_path=/path/to/MXB-imputed/MXB_b151_b38_QC
# related individuals up to the third degree (not included in this repository)
related_inds=/path/to/MXB_related_individuals.txt
# final sample IDs for the 5,833 individuals
sample_ids=/path/to/MXB-imputed.SAMPLE_ID

# load modules
module load bcftools tabix

set -e  # stop script on first error

chrom=${SLURM_ARRAY_TASK_ID}

mkdir -p $qc_path/QC_positions $qc_path/tmp
cd $qc_path

input_vcf=$in_path/MXB_6k.chr${chrom}.b151.numeric.rnamed.bi_allelic.vcf.gz

# 1. R2 > 0.01
awk '$6 > 0.01' $in_path/MXB_6k.chr${chrom}.bi_allelic.positions.tsv > QC_positions/MXB_6k.chr${chrom}.R2_threshold.positions.tsv
awk '{print $5}' QC_positions/MXB_6k.chr${chrom}.R2_threshold.positions.tsv > chr${chrom}.sites
sites_to_keep=chr${chrom}.sites

# 2. remove related individuals, recompute MAF and keep SNPs with R2 > 0.01 and MAF > 0.1%
bcftools view -S ^$related_inds $input_vcf | \
    bcftools +fill-tags -Oz -- -t MAF | \
    bcftools view --include "ID==@${sites_to_keep} && MAF>0.001" --threads 4 \
    -Oz -o tmp/MXB_5833.chr${chrom}.b151.numeric.rnamed.bi_allelic.QC.vcf.gz
tabix -p vcf tmp/MXB_5833.chr${chrom}.b151.numeric.rnamed.bi_allelic.QC.vcf.gz
rm $sites_to_keep

# 3. remove duplicated positions
bcftools query -f '%CHROM\t%POS\n' tmp/MXB_5833.chr${chrom}.b151.numeric.rnamed.bi_allelic.QC.vcf.gz > chr${chrom}.MXB_imputed_QC.sites
sort chr${chrom}.MXB_imputed_QC.sites | uniq -d > chr${chrom}.MXB_imputed_QC.sites_duplicated
bcftools view -T ^chr${chrom}.MXB_imputed_QC.sites_duplicated --threads 4 \
    tmp/MXB_5833.chr${chrom}.b151.numeric.rnamed.bi_allelic.QC.vcf.gz \
    -Oz -o tmp/MXB_5833.chr${chrom}.b151.numeric.rnamed.bi_allelic.QC_no_dups.vcf.gz
tabix -p vcf tmp/MXB_5833.chr${chrom}.b151.numeric.rnamed.bi_allelic.QC_no_dups.vcf.gz
rm chr${chrom}.MXB_imputed_QC.sites chr${chrom}.MXB_imputed_QC.sites_duplicated

# 4. fix sample IDs
bcftools reheader -s $sample_ids tmp/MXB_5833.chr${chrom}.b151.numeric.rnamed.bi_allelic.QC_no_dups.vcf.gz \
    -o MXB_5833.chr${chrom}.b151.numeric.rnamed.bi_allelic.QC_no_dups.vcf.gz
tabix -p vcf MXB_5833.chr${chrom}.b151.numeric.rnamed.bi_allelic.QC_no_dups.vcf.gz

echo "Done."
