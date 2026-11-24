#!/bin/bash
#SBATCH --time=12:00:00
#SBATCH --mem=10G
#SBATCH -o beagle_phasing_chrom_%a.out

### Written by Valeria Anorve-Garibay

# phase and impute missing genotypes with Beagle 5.5, without a reference panel
# run per chromosome; the output VCFs are the MXB-WGS dataset
# e.g. 'sbatch --array=1-22 14.BeaglePhasing.sh'

# paths
base_path=/path/to/IndigenousMXB
qc_path=$base_path/VCF_QC
beagle_jar=/path/to/beagle.27Feb25.75f.jar
# PLINK-format GRCh38 genetic maps from Beagle: https://bochet.gcc.biostat.washington.edu/beagle/genetic_maps/
genetic_map_dir=/path/to/plink.GRCh38.map

# load modules
module load openjdk/17.0.5_8-pq2e7ao tabix

set -e  # stop script on first error

chrom=${SLURM_ARRAY_TASK_ID}
genetic_map=$genetic_map_dir/plink.chr${chrom}.GRCh38.map
input_vcf=$qc_path/indigenous_mxb_filtered_SNPs_GRCh38_autosomes.QC.vcf.gz
out=$qc_path/phased_panel/indigenous_mxb_filtered_SNPs_GRCh38.chr${chrom}.QC.phased

mkdir -p $qc_path/phased_panel

java -Xmx10g -jar $beagle_jar \
    gt=$input_vcf \
    map=$genetic_map \
    chrom=chr${chrom} \
    out=$out
tabix -p vcf $out.vcf.gz

echo "Done."
