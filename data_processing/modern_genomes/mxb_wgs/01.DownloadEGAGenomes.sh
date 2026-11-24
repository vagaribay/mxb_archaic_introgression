#!/bin/bash
#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=10G

### Written by Valeria Anorve-Garibay

# run pyEGA3 to download the FASTQ files from EGA
# $1: file with one EGAF accession id per line
# e.g. 'sbatch --array=1-n_total_files 01.DownloadEGAGenomes.sh egaf_ids.txt'

# paths
base_path=/path/to/IndigenousMXB
CREDENTIALS_FILE=/path/to/CREDENTIALS_FILE
fastq_dir=$base_path/fasta

# activate conda environment with pyega3
conda activate baseline

cd $fastq_dir
line=${SLURM_ARRAY_TASK_ID}

# file with EGAF accession id
file_accession_id=$(sed -n "${line}p" $1)
if [[ -d "$file_accession_id" && $(ls -la "$file_accession_id" | wc -l) -eq 6 ]]; then
    echo "$file_accession_id exists and is not empty. Terminating for $line." >> OUT
else
    echo "Directory does not exist or is empty. Downloading $file_accession_id: $line" >> OUT
    pyega3 -c 10 -cf $CREDENTIALS_FILE fetch $file_accession_id
    # check if the directory is now non-empty
    if [[ -d "$file_accession_id" && $(ls -la "$file_accession_id" | wc -l) -eq 6 ]]; then
        echo "Download successful for $file_accession_id: $line" >> OUT
    else
        echo "Download failed for $file_accession_id: $line. Retrying once..." >> OUT
        pyega3 -c 10 -cf $CREDENTIALS_FILE fetch $file_accession_id
        # final check after retry
        if [[ -d "$file_accession_id" && $(ls -la "$file_accession_id" | wc -l) -eq 6 ]]; then
            echo "Retry successful for $file_accession_id: $line" >> OUT
        else
            echo "Retry failed for $file_accession_id: $line. Manual intervention needed." >> OUT
        fi
    fi
fi
