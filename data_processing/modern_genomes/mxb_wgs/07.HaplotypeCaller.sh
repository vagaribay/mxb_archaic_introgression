#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=10G
#SBATCH -o variant_calling_sample_%a.out
#SBATCH -e variant_calling_sample_%a.out

### Written by Valeria Anorve-Garibay

# per-sample variant calling with GATK HaplotypeCaller in GVCF mode
# e.g. 'sbatch --array=1-50 07.HaplotypeCaller.sh': average run time per sample: 25 hours

start=`date +%s`

# paths
base_path=/path/to/IndigenousMXB
sample_file=$base_path/MXB_50_WGS_sample_file.txt
bam_dir=$base_path/bam_GRCh38
vcf_dir=$base_path/VCF_GRCh38
scratch=/path/to/scratch
# human reference genome GRCh38 (see 03.MappingToGRCh38.sh)
reference_fasta=/path/to/GRCh38.p13.rCRS.fasta.gz

# load modules
module load gatk samtools
module load openjdk/11.0.17_8-nw5ylvi

set -e  # stop script on first error

n_sample='Sample'${SLURM_ARRAY_TASK_ID}
SAMPLE_ID=$(grep -w $n_sample $sample_file | awk '{print $2}' | head -n1)

echo "Variant Calling for $n_sample: $SAMPLE_ID"

mkdir -p $vcf_dir/$n_sample
mkdir -p $scratch/$SLURM_JOBID

# 1. HaplotypeCaller
echo "Calling variants using gatk HaplotypeCaller..."
gatk --java-options "-Djava.io.tmpdir=$scratch/$SLURM_JOBID -Xms8G -Xmx8G -XX:ParallelGCThreads=2" HaplotypeCaller \
    -R $reference_fasta \
    -I $bam_dir/$n_sample/$SAMPLE_ID.aln-bwa.csorted.fm.rmdup.RG.BQSR.bam \
    -O $vcf_dir/$n_sample/$SAMPLE_ID.raw.SNPs.INDELs.vcf.gz \
    -ERC GVCF

end=`date +%s`
runtime=$((end-start))
echo "Done."
echo "run time: $runtime"
