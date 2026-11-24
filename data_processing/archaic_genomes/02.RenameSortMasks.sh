#!/bin/bash
#SBATCH --time=12:00:00
#SBATCH --mem=10G

### Written by Valeria Anorve-Garibay

# standardize and sort the GRCh38 masks
# 1. rename chromosomes: from N to chrN
# 2. sort with bedtools
# e.g. 'sbatch 02.RenameSortMasks.sh'

# paths
base_dir=/path/to/archaic_genomes/GRCh38/FilterBed

# load modules
module load bedtools

for sample in AltaiNeandertal Vindija33.19 Denisova Chagyrskaya-Phalanx; do
    dir=$base_dir/$sample
    echo "Processing directory: $dir"
    for file in "$dir"/chr*_mask.bed; do
        echo "Processing $file..."
        # 1. rename chromosomes
        awk 'BEGIN {OFS="\t"} { $1="chr"$1; print }' "$file" > "${file%.bed}_renamed.bed"
        # 2. sort
        bedtools sort -i "${file%.bed}_renamed.bed" > "${file%.bed}_renamed.sorted.bed"
    done
done
