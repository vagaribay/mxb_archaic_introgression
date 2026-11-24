__author__ = 'vagaribay'

import argparse, pandas as pd

USAGE = """

find_shared_sites_btw_data_cohorts.py -v1 -v2 -o

find shared, mismatched and unique sites between two data cohorts
-v1, -v2: tab-separated files with CHROM, POS, REF, ALT in the first four columns (no header)
-o: output prefix

outputs:
- {out_prefix}_shared.tsv: exact matches (CHROM, POS, REF, ALT)
- {out_prefix}_shared_chrom_pos.tsv: matches on CHROM and POS
- {out_prefix}_mismatched.tsv: same CHROM and POS, different REF/ALT
- {out_prefix}_unique_vcf1.tsv, {out_prefix}_unique_vcf2.tsv: variants unique to each cohort

"""

parser = argparse.ArgumentParser(description="Find shared sites between data cohorts", usage=USAGE)

parser.add_argument('-v1', '--vcf1', action="store", dest="vcf1", help="sites file for cohort 1", default=None, type=str)
parser.add_argument('-v2', '--vcf2', action="store", dest="vcf2", help="sites file for cohort 2", default=None, type=str)
parser.add_argument('-o', '--out_prefix', action="store", dest="out_prefix", help="output prefix", default=None, type=str)

args = parser.parse_args()

vcf1 = pd.read_csv(args.vcf1, sep="\t", header=None, usecols=[0, 1, 2, 3],
                   names=["CHROM", "POS", "REF", "ALT"])

vcf2 = pd.read_csv(args.vcf2, sep="\t", header=None, usecols=[0, 1, 2, 3],
                   names=["CHROM", "POS", "REF", "ALT"])

# exact matches
intersection = pd.merge(vcf2, vcf1, how='inner', on=['CHROM', 'POS', 'REF', 'ALT'])
intersection.to_csv(f"{args.out_prefix}_shared.tsv", sep="\t", index=False, header=False)

# matches on CHROM and POS
intersection_pos = pd.merge(vcf2, vcf1, how='inner', on=['CHROM', 'POS'])
intersection_pos.to_csv(f"{args.out_prefix}_shared_chrom_pos.tsv", sep="\t", index=False, header=False)

# find mismatched REF/ALT but same CHROM and POS
mismatched = pd.merge(vcf1, vcf2, how='inner', on=['CHROM', 'POS'])
mismatched = mismatched[(mismatched['REF_x'] != mismatched['REF_y']) | (mismatched['ALT_x'] != mismatched['ALT_y'])]
mismatched.to_csv(f"{args.out_prefix}_mismatched.tsv", sep="\t", index=False, header=False)

# variants unique to vcf1
unique_vcf1 = vcf1.merge(vcf2, how="left", on=["CHROM", "POS", "REF", "ALT"], indicator=True)
unique_vcf1 = unique_vcf1[unique_vcf1["_merge"] == "left_only"].drop(columns=["_merge"])
unique_vcf1.to_csv(f"{args.out_prefix}_unique_vcf1.tsv", sep="\t", index=False, header=False)

# variants unique to vcf2
unique_vcf2 = vcf2.merge(vcf1, how="left", on=["CHROM", "POS", "REF", "ALT"], indicator=True)
unique_vcf2 = unique_vcf2[unique_vcf2["_merge"] == "left_only"].drop(columns=["_merge"])
unique_vcf2.to_csv(f"{args.out_prefix}_unique_vcf2.tsv", sep="\t", index=False, header=False)
