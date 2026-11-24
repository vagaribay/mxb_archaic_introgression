#!/bin/bash
#SBATCH --time=60:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=25G
#SBATCH -o gdb_chrom_%a.out
#SBATCH -e gdb_chrom_%a.out

### Written by Valeria Anorve-Garibay

# joint genotyping of the 50 samples per autosome
# e.g. 'sbatch --array=1-22 08.GVCF-calling.sh'

start=`date +%s`

# paths
base_path=/path/to/IndigenousMXB
sample_file=$base_path/MXB_50_WGS_sample_file.txt
vcf_dir=$base_path/VCF_GRCh38
genomicsdb_dir=$base_path/GenomicsDB_GRCh38
scratch=/path/to/scratch
# human reference genome GRCh38 (see 03.MappingToGRCh38.sh)
reference_fasta=/path/to/GRCh38.p13.rCRS.fasta.gz
build=GRCh38

# load modules
module load gatk samtools
module load openjdk/11.0.17_8-nw5ylvi

set -e  # stop script on first error

chrom=${SLURM_ARRAY_TASK_ID}
sample_map=$base_path/indigenous_mxb.sample_map.$build

# create sample map
# run once before submitting the array, e.g. 'bash 08.GVCF-calling.sh make_map'
if [[ "$1" == "make_map" ]]; then
    for i in {1..50}; do
        n_sample='Sample'${i}
        SAMPLE_ID=$(grep -w $n_sample $sample_file | awk '{print $2}' | head -n1)
        echo -e "${SAMPLE_ID}\t$vcf_dir/$n_sample/$SAMPLE_ID.raw.SNPs.INDELs.vcf.gz" >> $sample_map
    done
    exit 0
fi

mkdir -p $genomicsdb_dir
mkdir -p $scratch/GenomicsDBImport_tmp/${chrom}

# 1. Run GenomicsDBImport
echo "Running GenomicsDBImport for chrom: ${chrom}..."
gatk --java-options "-Xms20G -Xmx20G -XX:ParallelGCThreads=2" GenomicsDBImport \
    --genomicsdb-workspace-path $genomicsdb_dir/GVCF.chrom${chrom}.db \
    --sample-name-map $sample_map \
    --tmp-dir $scratch/GenomicsDBImport_tmp/${chrom} \
    -L ${chrom}

# 2. Run GenotypeGVCFs
echo "Running GenotypeGVCFs..."
gatk --java-options "-Xms20G -Xmx20G -XX:ParallelGCThreads=2" GenotypeGVCFs \
    -R $reference_fasta \
    -V gendb://$genomicsdb_dir/GVCF.chrom${chrom}.db \
    -O $vcf_dir/indigenous_mxb_raw_${build}.chrom${chrom}.vcf.gz \
    --tmp-dir $scratch/GenomicsDBImport_tmp/${chrom}

end=`date +%s`
runtime=$((end-start))
echo "Done."
echo "run time: $runtime"
