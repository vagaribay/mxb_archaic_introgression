# data_processing/modern_genomes/mxb_imputed

Scripts used for quality control and validation of the MXB imputed data (SI 2), run on the Brown University Oscar cluster (SLURM). Paths at the top of each script are placeholders.

The genotyped data (6,011 individuals, Illumina MEGA array) were phased and imputed by the data providers with the TOPMed reference panel on the Michigan Imputation Server (v1.3.3; Eagle v2.4, minimac4 v1.0.2). The imputed dataset has 292,323,482 variants (SNVs and InDels).

| Step | Script | Run as |
|---|---|---|
| 1 | `01.PreProcessing.sh` | `sbatch --array=1-22 01.PreProcessing.sh` |
| 2 | `02.VariantsReport.sh` | `bash 02.VariantsReport.sh` |
| 3 | `03.BiallelicSNPs.sh` | `sbatch --array=1-22 03.BiallelicSNPs.sh` |
| 4 | `04.ExtractSNPsInfo.sh` | `sbatch --array=1-22 04.ExtractSNPsInfo.sh` |
| 5 | `05.IntersectWithMXB-WGS.sh` | `sbatch --array=1-22 05.IntersectWithMXB-WGS.sh` |
| 6 | `06.ImputationPerformance.sh` (runs `06.ImputationPerformance.py`) | `sbatch --array=1-22 06.ImputationPerformance.sh` |
| 7 | `07.QC.sh` | `sbatch --array=1-22 07.QC.sh` |

`find_shared_sites_btw_data_cohorts.py` finds shared, mismatched and unique sites between two cohorts (used in step 5).

- Bi-allelic SNPs (step 3): 271,420,326 SNPs.
- Imputation performance (steps 5-6): the 50 individuals with WGS data (MXB-WGS, `../mxb_wgs`), 7,207,089 shared bi-allelic SNPs. Per-SNP genotype concordance and Pearson's R between dosages, for imputed markers. Plotted in `figure_nbs/SuppFig1_ImputationPerformance.R`.
- MXB-imputed (step 7): related individuals up to the third degree removed, R2 > 0.01, MAF > 0.1% and no duplicated positions. 5,833 individuals and 17,176,220 SNPs.

Final output (MXB-imputed): `MXB_b151_b38_QC/MXB_5833.chr{1..22}.b151.numeric.rnamed.bi_allelic.QC_no_dups.vcf.gz`

## Software

bcftools, tabix, Python 3 (scikit-allel, numpy, pandas), R (dplyr, ggplot2, cowplot, ggpubr). TODO: versions.

## Data

The MXB data are available under controlled access through TODO.
