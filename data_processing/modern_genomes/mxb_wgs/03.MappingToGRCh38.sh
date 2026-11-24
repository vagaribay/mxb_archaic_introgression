#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=18G

### Written by Valeria Anorve-Garibay

# run bwa mem to map paired-end reads against the human reference genome
# e.g. 'sbatch --array=1-50 03.MappingToGRCh38.sh': average run time per sample: 16 hours

# paths
base_path=/path/to/IndigenousMXB
sample_file=$base_path/MXB_50_WGS_sample_file.txt
fastq_dir=$base_path/fasta
bam_dir=$base_path/bam_GRCh38
# human reference genome GRCh38, prepared by Viridiana Villa-Islas
# downloaded from https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000001405.39/ (GRCh38.p13)
# only autosomes and sex chromosomes were kept, and the mitochondrial genome was replaced with the rCRS
# chromosomes are named 1-22, X, Y (no chr prefix)
reference_fasta=/path/to/GRCh38.p13.rCRS.fasta.gz

# load modules
module load bwa samtools
module load openjdk/11.0.17_8-nw5ylvi

# get R1 and R2 for this sample from the sample file
n_sample='Sample'${SLURM_ARRAY_TASK_ID}
grep -w $n_sample $sample_file | awk '{print $3, $4}' > tmp.$n_sample
mapfile -t file_name < <(awk '{print $1}' tmp.$n_sample)
mapfile -t dir_name < <(awk '{print $2}' tmp.$n_sample)
SAMPLE_ID=$(echo ${file_name[0]} | cut -d'_' -f1,2)
R1=$fastq_dir/${dir_name[0]}/${file_name[0]}
R2=$fastq_dir/${dir_name[1]}/${file_name[1]}

mkdir -p $bam_dir/$n_sample

echo "author: Valeria Anorve-Garibay on"  `date`
# BWA-MEM to align paired-end reads
echo "Mapping $n_sample: $SAMPLE_ID to human-build GRCh38..."
bwa mem \
    -M \
    -t 10 \
    -R "@RG\tID:$SAMPLE_ID\tPL:illumina\tPU:$SAMPLE_ID\tSM:$SAMPLE_ID" \
    $reference_fasta \
    $R1 \
    $R2 \
    -o $bam_dir/$n_sample/$SAMPLE_ID.aln-bwa.sam

# convert sam file to bam file
echo "Converting sam file to bam file..."
samtools view -h -b -S $bam_dir/$n_sample/$SAMPLE_ID.aln-bwa.sam > $bam_dir/$n_sample/$SAMPLE_ID.aln-bwa.bam

echo "Done."

rm "${bam_dir:?}"/"${n_sample:?}"/"${SAMPLE_ID:?}".aln-bwa.sam
rm tmp.$n_sample
