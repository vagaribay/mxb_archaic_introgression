#!/bin/bash
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=10G

### Written by Valeria Anorve-Garibay

# Quality control of Indigenous-MXB genetic data
# 1. filter bi-allelic SNPs (8,952,934 SNPs)
# 2. filter out monomorphic sites (8,573,291 SNPs)
# 3. quality metrics on the QC VCF
# e.g. 'sbatch 13.VCF-QC.sh'

# paths
base_path=/path/to/IndigenousMXB
input_vcf=$base_path/indigenous_mxb_filtered_SNPs_GRCh38_autosomes.vcf.gz
qc_path=$base_path/VCF_QC

# load modules
module load bcftools tabix vcftools

set -e  # stop script on first error

mkdir -p $qc_path/metrics
cd $qc_path

# 1. Filter bi-allelic SNPs
bcftools view -m2 -M2 --threads 4 $input_vcf -Oz -o tmp1.vcf.gz

# 2. Filter out monomorphic sites
bcftools filter -e 'AC==0 || AC==AN' --threads 4 tmp1.vcf.gz -Oz -o indigenous_mxb_filtered_SNPs_GRCh38_autosomes.QC.vcf.gz
rm tmp1.vcf.gz
tabix -p vcf indigenous_mxb_filtered_SNPs_GRCh38_autosomes.QC.vcf.gz

# 3. Quality metrics
# mean depth per individual
vcftools --gzvcf indigenous_mxb_filtered_SNPs_GRCh38_autosomes.QC.vcf.gz --depth --out metrics/ind_avg_depth
# proportion of missing data per individual
vcftools --gzvcf indigenous_mxb_filtered_SNPs_GRCh38_autosomes.QC.vcf.gz --missing-indv --out metrics/missing_data_x_ind
# proportion of missing data per site
vcftools --gzvcf indigenous_mxb_filtered_SNPs_GRCh38_autosomes.QC.vcf.gz --missing-site --out metrics/missing_data_x_site
# allele frequencies
vcftools --gzvcf indigenous_mxb_filtered_SNPs_GRCh38_autosomes.QC.vcf.gz --freq2 --out metrics/allele_freq

echo "Done."
