#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=10G

### Written by Valeria Anorve-Garibay

# extract SNP information from the bi-allelic VCF: position, ID, R2 (minimac4), marker type, AF and MAF
# marker type: TYPED_ONLY (genotyped but not imputed), TYPED (genotyped and imputed), IMPUTED (imputed but not genotyped)
# columns: CHROM, POS, REF, ALT, ID, R2, TYPED_ONLY, TYPED, TYPE, AF, MAF
# e.g. 'sbatch --array=1-22 04.ExtractSNPsInfo.sh'

# paths
out_path=/path/to/MXB-imputed/MXB_b151_b38

# load modules
module load bcftools

set -e  # stop script on first error

chrom=${SLURM_ARRAY_TASK_ID}

cd $out_path

bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%ID\t%R2\t%INFO/TYPED_ONLY\t%INFO/TYPED\t%INFO/IMPUTED\t%INFO/AF\t%INFO/MAF\n' \
    MXB_6k.chr${chrom}.b151.numeric.rnamed.bi_allelic.vcf.gz | \
    awk '{
        type = ($7 == "1" ? "TYPED_ONLY" : ($8 == "1" ? "TYPED" : ($9 == "1" ? "IMPUTED" : "UNKNOWN")));
        print $1, $2, $3, $4, $5, $6, $7, $8, type, $10, $11;
    }' OFS="\t" > MXB_6k.chr${chrom}.bi_allelic.positions.tsv

echo "Done."
