# data_processing/modern_genomes/mxb_wgs

Scripts used for alignment and variant calling of the 50 MXB whole genomes (GRCh38), run on the Brown University Oscar cluster (SLURM). Paths at the top of each script are placeholders.

| Step | Script | Run as |
|---|---|---|
| 1 | `01.DownloadEGAGenomes.sh` | `sbatch --array=1-n_files 01.DownloadEGAGenomes.sh egaf_ids.txt` |
| 2 | `02.fastQC.sh` | `sbatch 02.fastQC.sh` |
| 3 | `03.MappingToGRCh38.sh` | `sbatch --array=1-50 03.MappingToGRCh38.sh` |
| 4 | `04.BamPreProcessing.sh` | `sbatch --array=1-50 04.BamPreProcessing.sh` |
| 5 | `05.Alignment_WGSCoverage_QC.sh` | `sbatch 05.Alignment_WGSCoverage_QC.sh` |
| 6 | `06.BaseRecalibration.sh` | `sbatch --array=1-50 06.BaseRecalibration.sh` |
| 7 | `07.HaplotypeCaller.sh` | `sbatch --array=1-50 07.HaplotypeCaller.sh` |
| 8 | `08.GVCF-calling.sh` | `bash 08.GVCF-calling.sh make_map`, then `sbatch --array=1-22 08.GVCF-calling.sh` |
| 9 | `09.VCFsGathering.sh` | `sbatch 09.VCFsGathering.sh` |
| 10 | `10.VCF-HardFiltering.sh` | `sbatch 10.VCF-HardFiltering.sh` |
| 11 | `11.RenameChrVCF.sh` | `sbatch 11.RenameChrVCF.sh` |
| 12 | `12.ExtractSNPs_InDels.sh` | `sbatch 12.ExtractSNPs_InDels.sh` |
| 13 | `13.VCF-QC.sh` | `sbatch 13.VCF-QC.sh` |
| 14 | `14.BeaglePhasing.sh` | `sbatch --array=1-22 14.BeaglePhasing.sh` |

Filtered VCF (steps 1-12): 50 individuals, 11,138,767 variants on the autosomes.

QC (step 13): bi-allelic SNPs only (8,952,934), then no monomorphic sites (8,573,291). Output: `VCF_QC/indigenous_mxb_filtered_SNPs_GRCh38_autosomes.QC.vcf.gz`. QC metrics (depth, missingness per individual and per site, allele frequencies) are in `VCF_QC/metrics/`.

Phasing (step 14): the few missing genotypes (0.00048%) were imputed and all genotypes phased with Beagle 5.5 (beagle.27Feb25.75f.jar) per chromosome, using the PLINK GRCh38 genetic maps and no reference panel.

Final output (MXB-WGS, 8,573,291 SNPs): `VCF_QC/phased_panel/indigenous_mxb_filtered_SNPs_GRCh38.chr{1..22}.QC.phased.vcf.gz`

## Reference genome

GRCh38.p13 (GCF_000001405.39), prepared by Viridiana Villa-Islas. Only autosomes and sex chromosomes were kept, and the mitochondrial genome was replaced with the rCRS.

## Software

TODO: versions for bwa, samtools, picard, GATK (4.3.0.0 for BQSR), FastQC (0.12.1), MultiQC, bcftools, pyega3, DISCVRSeq (1.3.84), Beagle (5.5, beagle.27Feb25.75f.jar), vcftools.

## Data

FASTQ files are available under controlled access from EGA (TODO: EGAD accession).
