# data_processing/modern_genomes/mxb_wgs

Alignment and variant calling for the 50 MXB whole genomes (GRCh38).

Edit `config.sh` with your paths, then submit every script from this folder.

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

Final output: `indigenous_mxb_filtered_SNPs_GRCh38_autosomes.vcf.gz`

## Software

TODO: versions for bwa, samtools, picard, GATK (4.3.0.0 for BQSR), FastQC (0.12.1), MultiQC, bcftools, pyega3, DISCVRSeq (1.3.84).

## Data

FASTQ files are available under controlled access from EGA (TODO: EGAD accession).

