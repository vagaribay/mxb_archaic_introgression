#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=35G
#SBATCH -o vcf_hard_filtering.out

### Written by Valeria Anorve-Garibay

# GATK hard filtering of SNPs and InDels
# GATK Best Practices: https://gatk.broadinstitute.org/hc/en-us/articles/360035531112--How-to-Filter-variants-either-with-VQSR-or-by-hard-filtering
# e.g. 'sbatch 10.VCF-HardFiltering.sh'

start=`date +%s`

# paths
base_path=/path/to/IndigenousMXB
vcf_dir=$base_path/VCF_GRCh38
out_path=$vcf_dir/VCF_merged
# human reference genome GRCh38 (see 03.MappingToGRCh38.sh)
reference_fasta=/path/to/GRCh38.p13.rCRS.fasta.gz
discvrseq_jar=/path/to/DISCVRSeq-1.3.84.jar
build=GRCh38

# load modules
module load gatk samtools tabix bcftools
module load openjdk/11.0.17_8-nw5ylvi

set -e  # stop script on first error

raw=$out_path/indigenous_mxb_raw_${build}

# 1. Filter SNPs
echo "Filtering SNPs..."
gatk --java-options "-Xms32G -Xmx32G -XX:ParallelGCThreads=8" SelectVariants \
    --select-type-to-include SNP \
    -V $raw.vcf.gz \
    --output $raw.SNPs.vcf.gz
gatk --java-options "-Xms32G -Xmx32G -XX:ParallelGCThreads=8" VariantFiltration \
    -R $reference_fasta \
    -V $raw.SNPs.vcf.gz \
    -filter "QD < 2.0" --filter-name "QD2" \
    -filter "MQ < 40.0" --filter-name "MQ40" \
    -filter "FS > 60.0" --filter-name "FS60" \
    -filter "SOR > 3.0" --filter-name "SOR3" \
    -filter "MQRankSum < -12.5" --filter-name "MQRankSum-12.5" \
    -filter "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum-8" \
    -filter "QUAL < 30.0" --filter-name "QUAL30" \
    -O $raw.SNPs.filtered.vcf.gz

# delete unfiltered SNPs file
rm "${raw:?}".SNPs.vcf.gz "${raw:?}".SNPs.vcf.gz.tbi

# 2. Filter InDels
echo "Filtering InDels..."
gatk --java-options "-Xms32G -Xmx32G -XX:ParallelGCThreads=8" SelectVariants \
    --select-type-to-exclude SNP \
    -V $raw.vcf.gz \
    --output $raw.InDels.vcf.gz
gatk --java-options "-Xms32G -Xmx32G -XX:ParallelGCThreads=8" VariantFiltration \
    -R $reference_fasta \
    -V $raw.InDels.vcf.gz \
    -filter "QD < 2.0" --filter-name "QD2" \
    -filter "FS > 200.0" --filter-name "FS200" \
    -filter "ReadPosRankSum < -20.0" --filter-name "ReadPosRankSum-20" \
    -O $raw.InDels.filtered.vcf.gz

# delete unfiltered InDels file
rm "${raw:?}".InDels.vcf.gz "${raw:?}".InDels.vcf.gz.tbi

# 3. Merge SNPs and InDels
echo "Merging SNPs and InDels..."
gatk --java-options "-Xms32G -Xmx32G -XX:ParallelGCThreads=8" MergeVcfs \
    -I $raw.SNPs.filtered.vcf.gz \
    -I $raw.InDels.filtered.vcf.gz \
    -O ${raw}_wFilterTag.vcf.gz

# 4. Keep only variants that pass the filters
echo "Keeping PASS variants..."
gatk --java-options "-Xms32G -Xmx32G -XX:ParallelGCThreads=8" SelectVariants \
    -R $reference_fasta \
    --variant ${raw}_wFilterTag.vcf.gz \
    --exclude-filtered \
    -O $out_path/indigenous_mxb_filtered_${build}.vcf.gz

rm "${raw:?}".SNPs.filtered.vcf.gz* "${raw:?}".InDels.filtered.vcf.gz*

# 5. VCF QC
echo "Computing VCF stats..."
mkdir -p $out_path/vcf_stats
java -jar $discvrseq_jar VariantQC \
    -R $reference_fasta \
    -V $out_path/indigenous_mxb_filtered_${build}.vcf.gz \
    -O $out_path/vcf_stats/indigenous_mxb_filtered_${build}_autosomes.stats.html
bcftools stats $out_path/indigenous_mxb_filtered_${build}.vcf.gz > $out_path/indigenous_mxb_filtered_${build}.stats

end=`date +%s`
runtime=$((end-start))
echo "Done."
echo "run time: $runtime"
