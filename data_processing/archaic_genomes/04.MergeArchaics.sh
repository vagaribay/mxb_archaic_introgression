#!/bin/bash
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=10G

### Written by Valeria Anorve-Garibay

# merge the four masked archaic genomes into one VCF per chromosome
# e.g. 'sbatch --array=1-22 04.MergeArchaics.sh'

# paths
skov_path=/path/to/archaic_genomes/GRCh38/SkovFiles

# load modules
module load bcftools tabix

set -euo pipefail

chrom=${SLURM_ARRAY_TASK_ID}

cd $skov_path

bcftools merge -m none --threads 4 \
    AltaiNeandertal_chr${chrom}_QC.vcf.gz \
    Vindija33.19_chr${chrom}_QC.vcf.gz \
    Denisova_chr${chrom}_QC.vcf.gz \
    Chagyrskaya-Phalanx_chr${chrom}_QC.vcf.gz \
    -Oz -o individuals_highcov.QC.chr${chrom}.vcf.gz
tabix -p vcf individuals_highcov.QC.chr${chrom}.vcf.gz
