#!/bin/bash
#SBATCH --time=60:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=2G

### Written by Valeria Anorve-Garibay

# run fastQC for all R1 and R2 files
# e.g. 'sbatch 02.fastQC.sh'

# paths
base_path=/path/to/IndigenousMXB
sample_file=$base_path/MXB_50_WGS_sample_file.txt
fastq_dir=$base_path/fasta
fastqc_dir=$base_path/fastqc

# load modules
module load fastqc/0.12.1-sk2rb3a

mkdir -p $fastqc_dir

# list of FASTQ files from the sample file (file_accession_id/file_name)
fastq_files=$(awk -v dir=$fastq_dir '{print dir"/"$4"/"$3}' $sample_file)

echo "author: Valeria Anorve-Garibay on"  `date`
echo "Running fastQC for all samples..."
fastqc -o $fastqc_dir -t 16 $fastq_files

echo "Done."
