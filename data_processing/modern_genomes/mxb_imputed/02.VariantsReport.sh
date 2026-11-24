#!/bin/bash

### Written by Valeria Anorve-Garibay

# variants report from the bcftools stats of the raw imputed VCFs
# 292,323,482 records, 271,420,326 SNPs
# e.g. 'bash 02.VariantsReport.sh'

# paths
out_path=/path/to/MXB-imputed/MXB_b151_b38

cd $out_path

echo -e "f_name\tn_samples\tn_records\tn_no_ALTs\tn_snps\tn_mnps\tn_indels\tn_others\tn_multi\tn_multi_snp" > MXB_6k.imputed_raw.report.txt
for chrom in {1..22}; do
    grep -v '#' annot/MXB_6k.chr$chrom.b151.numeric.stats | \
        head -10 | awk -F'\t|: ' '{printf "%s\t", $NF} END {print ""}' >> MXB_6k.imputed_raw.report.txt
done
