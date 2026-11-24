#!/bin/bash
#SBATCH --time=12:00:00
#SBATCH --mem=10G

### Written by Valeria Anorve-Garibay

# lift over the MPI FilterBed files from hg19 to GRCh38 with CrossMap (https://crossmap.sourceforge.net/)
# FilterBed files downloaded from:
# Vindija33.19: http://ftp.eva.mpg.de/neandertal/Vindija/FilterBed/Vindija33.19/
# AltaiNeandertal: http://ftp.eva.mpg.de/neandertal/Vindija/FilterBed/Altai/
# Denisova: http://ftp.eva.mpg.de/neandertal/Vindija/FilterBed/Denisova/
# Chagyrskaya-Phalanx: http://ftp.eva.mpg.de/neandertal/Chagyrskaya/FilterBed/
# chain file: https://ftp.ensembl.org/pub/assembly_mapping/homo_sapiens/GRCh37_to_GRCh38.chain.gz
# $1: archaic genome (AltaiNeandertal, Vindija33.19, Denisova or Chagyrskaya-Phalanx)
# e.g. 'sbatch --array=1-22 01.LiftOverFilterBed.sh Denisova'

# paths
hg19_path=/path/to/archaic_genomes/hg19/FilterBed
grch38_path=/path/to/archaic_genomes/GRCh38/FilterBed
chain=/path/to/GRCh37_to_GRCh38.chain.gz

set -euo pipefail

# activate conda environment with CrossMap
conda activate liftOver

chrom=${SLURM_ARRAY_TASK_ID}
ARCHAIC=$1

mkdir -p $grch38_path/${ARCHAIC}

input_bed=$hg19_path/${ARCHAIC}/chr${chrom}_mask.bed.gz
output_bed=$grch38_path/${ARCHAIC}/chr${chrom}_mask.bed
CrossMap bed ${chain} ${input_bed} ${output_bed}
