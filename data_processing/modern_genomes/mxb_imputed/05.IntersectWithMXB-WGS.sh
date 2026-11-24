#!/bin/bash
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=20G

### Written by Valeria Anorve-Garibay

# shared SNPs between MXB-WGS and MXB-imputed, and subset of MXB-imputed for the 50 individuals with WGS data
# 7,207,089 shared bi-allelic SNPs (exact match on CHROM, POS, REF, ALT)
# 1. find shared sites
# 2. extract the INFO (04.ExtractSNPsInfo.sh) of the shared sites
# 3. extract shared sites and the 50 individuals from MXB-imputed
# e.g. 'sbatch --array=1-22 05.IntersectWithMXB-WGS.sh'

# paths
imputed_path=/path/to/MXB-imputed/MXB_b151_b38
wgs_qc_path=/path/to/IndigenousMXB/VCF_QC
out_path=/path/to/MXB-imputed/MXB_WGS_b151_b38
# sample IDs of the 50 individuals with WGS data
wgs_sample_ids=/path/to/indigenous_mxb_SAMPLE_IDs

# load modules
module load bcftools tabix
conda activate main

set -e  # stop script on first error

chrom=${SLURM_ARRAY_TASK_ID}

mkdir -p $out_path/qc_snps_info $out_path/positions $out_path/shared_positions
cd $out_path

# 1. Find shared sites
# MXB-WGS QC SNPs: CHROM, POS, REF, ALT
bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\n' \
    $wgs_qc_path/indigenous_mxb_filtered_SNPs_GRCh38_autosomes.QC.vcf.gz -r chr${chrom} \
    > qc_snps_info/chr${chrom}.MXB-WGS.QC.snps.tsv
vcf1=qc_snps_info/chr${chrom}.MXB-WGS.QC.snps.tsv
vcf2=$imputed_path/MXB_6k.chr${chrom}.bi_allelic.positions.tsv
python3 find_shared_sites_btw_data_cohorts.py -v1 ${vcf1} -v2 ${vcf2} -o positions/chr${chrom}.positions

# 2. Extract INFO for exact matches (shared positions)
awk 'NR==FNR {key[$1,$2,$3,$4] = $0; next} ($1,$2,$3,$4) in key {print key[$1,$2,$3,$4]}' \
    $imputed_path/MXB_6k.chr${chrom}.bi_allelic.positions.tsv \
    positions/chr${chrom}.positions_shared.tsv > shared_positions/chr${chrom}.positions_shared_INFO.tsv

# 3. Extract shared sites and the 50 individuals from MXB-imputed
awk '{print $5}' shared_positions/chr${chrom}.positions_shared_INFO.tsv > chr${chrom}.sites
sites_to_keep=chr${chrom}.sites
bcftools view -S $wgs_sample_ids \
    --include "ID==@${sites_to_keep}" \
    --threads 4 -Oz -o MXB_WGS.imputed_snps_matching_with_wgs.chr${chrom}.vcf.gz \
    $imputed_path/MXB_6k.chr${chrom}.b151.numeric.rnamed.bi_allelic.vcf.gz
tabix -p vcf MXB_WGS.imputed_snps_matching_with_wgs.chr${chrom}.vcf.gz
rm $sites_to_keep

echo "Done."
