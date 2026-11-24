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

Final output: `indigenous_mxb_filtered_SNPs_GRCh38_autosomes.vcf.gz`

## Reference genome

GRCh38.p13 (GCF_000001405.39), prepared by Viridiana Villa-Islas. Only autosomes and sex chromosomes were kept, and the mitochondrial genome was replaced with the rCRS.

## Data

The genotype for the 5,833 Mexican Biobank individuals are available at the European Genome-phenome Archive (EGA) through a Data Access Agreement with the Data Access Committee (EGA accession number for study: EGAS00001005797; datasets: EGAD00010002361 (Mexican_Biobank_Genotypes) and EGAD00001008354 (Mexican Biobank 50 Genomes)).
