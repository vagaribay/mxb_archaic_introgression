#!/bin/bash
#SBATCH -t 100:00:00
#SBATCH --mem=10g

### Written by Valeria Anorve-Garibay

# run hmmix (https://github.com/LauritsSkov/Introgression-detection) per haplotype
# 1. create_ingroup: observations for one haplotype
# 2. train: haploid model
# 3. decode: archaic tracts on the autosomes
# 4. decode with the high-coverage archaic genomes (-admixpop) to annotate each tract
# helpfiles were downloaded from https://zenodo.org/records/11212339 (GRCh38)
# $1: sample file, one ingroup individual per line
# $2: name for the output folders
# $3: input VCF(s), comma-separated
# e.g. 'sbatch --array=1-n_individuals 01.run_ingroup_train_decode.sh samples.txt MXB <vcfs>'

# paths
helpfiles=/path/to/hmmix/helpfiles

# activate conda environment with hmmix
conda activate hmmix

# load modules
module load bcftools vcftools

start_time=$(date +%s)

sample_file=$1
name=$2
VCFs=$3

ingroup_hap=`cat $sample_file | awk -v line=$SLURM_ARRAY_TASK_ID '{if (NR == line) print $0}'`
echo "ind: "$ingroup_hap

# hmmix helpfiles
weights=$helpfiles/hg38_strick_callability_mask.bed
mutrates=$helpfiles/hg38_mutationrate.bed
outgroup=$helpfiles/hg38_Outgroup_1000g_HGDP.txt
ancestral=$(for i in {1..22}; do printf "%s," $helpfiles/hg38_ancestral/homo_sapiens_ancestor_$i.fa; done | sed 's/,$//')
archaic_bcfs=$(for i in {1..22}; do printf "%s," $helpfiles/archaicvar/individuals_highcov.$i.bcf; done | sed 's/,$//')

mkdir -p obs_files/${name} trained_files/${name} decoded_autosomes/${name}

# 1. create_ingroup
echo "create_ingroup is starting"
hmmix create_ingroup -ind=$ingroup_hap -vcf=$VCFs -weights=$weights -out=obs_files/${name}/obs \
    -outgroup=$outgroup \
    -ancestral=$ancestral

ingroup_file=obs_files/${name}/obs.${ingroup_hap}.txt

# 2. train
echo "train is starting"
trained_file=trained_files/${name}/trained.${ingroup_hap}.haploid.json
hmmix train -obs=$ingroup_file -weights=$weights -mutrates=$mutrates -out=$trained_file -haploid

# 3. decode autosomes
echo "decode is starting for autosomes"
decoded_file=decoded_autosomes/${name}/decoded.${ingroup_hap}.autosome
hmmix decode -obs=$ingroup_file -weights=$weights -mutrates=$mutrates -param=$trained_file -out=$decoded_file -haploid

# 4. decode autosomes with the archaic genomes
echo "decode with archaic ind is starting for autosomes"
hmmix decode -obs=$ingroup_file -weights=$weights -mutrates=$mutrates -param=$trained_file -out=$decoded_file.warchaicpop -haploid \
    -admixpop=$archaic_bcfs

end_time=$(date +%s)
runtime=$((end_time - start_time))
echo "Done."
echo "Total runtime: ${runtime} seconds"
