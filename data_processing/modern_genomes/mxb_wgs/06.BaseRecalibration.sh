#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4G
#SBATCH -o bsqr_sample_%a.out
#SBATCH -e bsqr_sample_%a.out

### Written by Valeria Anorve-Garibay

# base quality score recalibration (BQSR)
# e.g. 'sbatch --array=1-50 06.BaseRecalibration.sh': average run time per sample: 15 hours

start=`date +%s`

# paths
base_path=/path/to/IndigenousMXB
sample_file=$base_path/MXB_50_WGS_sample_file.txt
fastq_dir=$base_path/fasta
bam_dir=$base_path/bam_GRCh38
# human reference genome GRCh38 (see 03.MappingToGRCh38.sh)
reference_fasta=/path/to/GRCh38.p13.rCRS.fasta.gz
# GATK resource files for BQSR, downloaded from:
# https://console.cloud.google.com/storage/browser/genomics-public-data/resources/broad/hg38/v0
# chromosomes were renamed to match the reference fasta file
# bcftools annotate --rename-chrs rename_chroms.txt --threads 8 -o out.vcf.gz -Oz in.vcf.gz
# contigs were not renamed as they were removed from the reference fasta file
dbsnp=/path/to/Homo_sapiens_assembly38.dbsnp138.renamed.vcf.gz
mills=/path/to/Mills_and_1000G_gold_standard.indels.hg38.renamed.vcf.gz

# load modules
module load openjdk/11.0.17_8-nw5ylvi
module load gatk/4.3.0.0-234wqft
module load picard
module load samtools

n_sample='Sample'${SLURM_ARRAY_TASK_ID}
grep -w $n_sample $sample_file | head -n1 > $n_sample.tmp
SAMPLE_ID=$(awk '{print $2}' $n_sample.tmp)
EGAF_id=$(awk '{print $4}' $n_sample.tmp)
rm $n_sample.tmp

# read group ID and PU from the first FASTQ header (flowcell.lane)
fqheader=`zcat $fastq_dir/$EGAF_id/$SAMPLE_ID*.fastq.gz | head -1 | cut -d' ' -f1 - `
RGID=$(echo "${fqheader}" | awk 'BEGIN{FS=":";OFS="."}{print $3,$4}' - )
RGPU=$(echo -e "${RGID}.${SAMPLE_ID}" )

set -e  # stop script on first error

base_name=$bam_dir/$n_sample/$SAMPLE_ID.aln-bwa.csorted.fm.rmdup

echo "Base Recalibration for $n_sample: $SAMPLE_ID"

# 1. Add read groups to bam file and index new bam
echo "Replacing read groups in bam file..."
gatk AddOrReplaceReadGroups \
    -I $base_name.bam \
    -O $base_name.RG.bam \
    --RGID ${RGID} \
    --RGPU ${RGPU} \
    --RGLB ${SAMPLE_ID} \
    --RGPL Illumina \
    --RGSM ${SAMPLE_ID}

echo "Indexing..."
samtools index $base_name.RG.bam && rm "${base_name:?}".bam "${base_name:?}".bam.bai

# 2. Run BaseRecalibrator
echo "Running BaseRecalibrator..."
gatk BaseRecalibrator -R $reference_fasta \
    -I $base_name.RG.bam \
    --known-sites $dbsnp \
    --known-sites $mills \
    -O $bam_dir/$n_sample/BQSR.table

# 3. Apply BQSR
echo "Applying BQSR..."
gatk ApplyBQSR -R $reference_fasta \
    -I $base_name.RG.bam \
    --bqsr-recal-file $bam_dir/$n_sample/BQSR.table \
    -O $base_name.RG.BQSR.bam && rm "${base_name:?}".RG.bam "${base_name:?}".RG.bam.bai

end=`date +%s`
runtime=$((end-start))
echo "Done."
echo "run time: $runtime"
