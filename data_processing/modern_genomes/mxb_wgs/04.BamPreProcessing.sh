#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8G
#SBATCH -o bam_processing_sample_%a.out
#SBATCH -e bam_processing_sample_%a.out

### Written by Valeria Anorve-Garibay

# bam file pre-processing steps and alignment QC
# e.g. 'sbatch --array=1-50 04.BamPreProcessing.sh': average run time per sample: 6 hours

# paths
base_path=/path/to/IndigenousMXB
sample_file=$base_path/MXB_50_WGS_sample_file.txt
bam_dir=$base_path/bam_GRCh38
# human reference genome GRCh38 (see 03.MappingToGRCh38.sh)
reference_fasta=/path/to/GRCh38.p13.rCRS.fasta.gz

set -e  # stop script on first error

# load modules
module load samtools picard
module load openjdk/11.0.17_8-nw5ylvi

n_sample='Sample'${SLURM_ARRAY_TASK_ID}
SAMPLE_ID=$(grep -w $n_sample $sample_file | awk '{print $2}' | head -n1)

base_name=$bam_dir/$n_sample/$SAMPLE_ID.aln-bwa

# 1. Sort bam file by query name
echo "Sorting bam file by query name..."
samtools sort -@ 8 -n -o $base_name.qsorted.bam $base_name.bam

# 2. Fix mate information
echo "Fixing mate information..."
samtools fixmate -@ 8 -m $base_name.qsorted.bam $base_name.qsorted.fm.bam

# 3. Sort bam file by coordinate
echo "Sorting bam file by coordinate..."
samtools sort -@ 8 -o $base_name.csorted.fm.bam $base_name.qsorted.fm.bam

# 4. Mark and remove PCR duplicates
echo "Marking and removing duplicates..."
samtools markdup -r -@ 8 $base_name.csorted.fm.bam $base_name.csorted.fm.rmdup.bam
samtools index -@ 8 $base_name.csorted.fm.rmdup.bam

# keep filtered bam only
echo "Removing temporary files..."
rm "${base_name:?}".qsorted.bam "${base_name:?}".qsorted.fm.bam "${base_name:?}".csorted.fm.bam

# 5. Alignment and coverage QC
echo "Computing Alignment Summary Metrics..."
java -Xmx8G -jar $PICARD CollectAlignmentSummaryMetrics \
    --INPUT $base_name.csorted.fm.rmdup.bam \
    --REFERENCE_SEQUENCE $reference_fasta \
    --OUTPUT $base_name.csorted.fm.rmdup.AlignmentSummaryMetrics

echo "Computing WGS Coverage Metrics..."
java -Xmx8G -jar $PICARD CollectWgsMetrics \
    --INPUT $base_name.csorted.fm.rmdup.bam \
    --OUTPUT $base_name.csorted.fm.rmdup.WgsMetrics \
    --REFERENCE_SEQUENCE $reference_fasta

echo "Done."
