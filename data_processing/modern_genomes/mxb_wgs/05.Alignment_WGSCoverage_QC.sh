#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2G

### Written by Valeria Anorve-Garibay

# run multiQC for fastQC, AlignmentSummaryMetrics and WgsMetrics
# e.g. 'sbatch 05.Alignment_WGSCoverage_QC.sh'

# paths
base_path=/path/to/IndigenousMXB
fastqc_dir=$base_path/fastqc
multiqc_dir=$base_path/multiqc
bam_dir=$base_path/bam_GRCh38

# activate conda environment with multiqc
conda activate baseline

echo "author: Valeria Anorve-Garibay on"  `date`
echo "Running multiQC..."
find $fastqc_dir -name "*.zip" -exec multiqc -o $multiqc_dir/fastqc {} +
find $bam_dir -name "*.AlignmentSummaryMetrics" -exec multiqc -o $multiqc_dir/AlignmentSummaryMetrics {} +
find $bam_dir -name "*.WgsMetrics" -exec multiqc -o $multiqc_dir/WgsMetrics {} +
