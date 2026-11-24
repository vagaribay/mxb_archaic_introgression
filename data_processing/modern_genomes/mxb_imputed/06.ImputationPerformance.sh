#!/bin/bash
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=6
#SBATCH --mem=20G

### Written by Valeria Anorve-Garibay

# imputation performance of MXB-imputed against MXB-WGS, per chromosome
# e.g. 'sbatch --array=1-22 06.ImputationPerformance.sh'

# paths
shared_path=/path/to/MXB-imputed/MXB_WGS_b151_b38
wgs_phased_path=/path/to/IndigenousMXB/VCF_QC/phased_panel
out_path=/path/to/imputation_performance

conda activate main

set -e  # stop script on first error

chrom=${SLURM_ARRAY_TASK_ID}

mkdir -p $out_path

python3 06.ImputationPerformance.py \
    -v1 $shared_path/MXB_WGS.imputed_snps_matching_with_wgs.chr${chrom}.vcf.gz \
    -v2 $wgs_phased_path/indigenous_mxb_filtered_SNPs_GRCh38.chr${chrom}.QC.phased.vcf.gz \
    -i $shared_path/shared_positions/chr${chrom}.positions_shared_INFO.tsv \
    -c $chrom \
    -o $out_path/chr${chrom}.MXB_imputed.imputation.performance.for_snps_matching_with_wgs.tsv
