Scripts used for quality control and validation of the MXB imputed data (SI 2), run on the Brown University Oscar cluster (SLURM). Paths at the top of each script are placeholders.

The genotyped data (6,011 individuals, Illumina MEGA array) were phased and imputed by the data providers with the TOPMed reference panel on the Michigan Imputation Server (v1.3.3; Eagle v2.4, minimac4 v1.0.2). The imputed dataset has 292,323,482 variants (SNVs and InDels).

`find_shared_sites_btw_data_cohorts.py` finds shared, mismatched and unique sites between two cohorts (used in step 5).

- Bi-allelic SNPs (step 3): 271,420,326 SNPs.
- Imputation performance (steps 5-6): the 50 individuals with WGS data (MXB-WGS, `../mxb_wgs`), 7,207,089 shared bi-allelic SNPs. Per-SNP genotype concordance and Pearson's R between dosages, for imputed markers. Plotted in `figure_nbs/SuppFig1_ImputationPerformance.R`.
- MXB-imputed (step 7): related individuals up to the third degree removed, R2 > 0.01, MAF > 0.1% and no duplicated positions. 5,833 individuals and 17,176,220 SNPs.
