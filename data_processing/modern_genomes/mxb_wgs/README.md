Scripts used for alignment, variant calling and QC of the 50 MXB whole genomes (GRCh38), run on the Brown University Oscar cluster (SLURM). Paths at the top of each script are placeholders.

## Reference genome

GRCh38.p13 (GCF_000001405.39), prepared by Viridiana Villa-Islas. Only autosomes and sex chromosomes were kept, and the mitochondrial genome was replaced with the rCRS.

## Software

Versions for bwa, samtools, picard, GATK (4.3.0.0 for BQSR), FastQC (0.12.1), MultiQC, bcftools, pyega3, DISCVRSeq (1.3.84), Beagle (5.5, beagle.27Feb25.75f.jar), vcftools.

## Data

The genotype and phenotype datasets for the 5,833 Mexican Biobank individuals are available at the European Genome-phenome Archive (EGA) through a Data Access Agreement with the Data Access Committee (EGA accession number for study: EGAS00001005797; datasets: EGAD00010002361 (Mexican_Biobank_Genotypes) and EGAD00001008354 (Mexican Biobank 50 Genomes)).
