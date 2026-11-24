__author__ = 'vagaribay'

import allel, argparse, numpy as np, pandas as pd
import warnings
warnings.simplefilter("ignore", category=RuntimeWarning)

USAGE = """

06.ImputationPerformance.py -v1 -v2 -i -c -o

per-SNP imputation performance of MXB-imputed against MXB-WGS ("true" genotypes) for the 50 shared individuals
- genotype concordance: proportion of correctly imputed genotypes (phasing ignored)
- Pearson's R: correlation between imputed and WGS genotype dosages

-v1: MXB-imputed VCF, 50 individuals, shared sites only (05.IntersectWithMXB-WGS.sh)
-v2: MXB-WGS VCF for the same chromosome
-i: chrN.positions_shared_INFO.tsv (05.IntersectWithMXB-WGS.sh)
-c: chromosome number
-o: output file

e.g. python3 06.ImputationPerformance.py -v1 MXB_50.chr22.shared_sites.vcf.gz -v2 MXB-WGS.chr22.vcf.gz -i shared_positions/chr22.positions_shared_INFO.tsv -c 22 -o imputation_performance/chr22.imputation_performance.tsv

"""

parser = argparse.ArgumentParser(usage=USAGE)

parser.add_argument('-v1', '--vcf1', action="store", dest="vcf_1", help="MXB-imputed VCF", default=None, type=str)
parser.add_argument('-v2', '--vcf2', action="store", dest="vcf_2", help="MXB-WGS VCF", default=None, type=str)
parser.add_argument('-i', '--info', action="store", dest="info_file", help="shared positions INFO file", default=None, type=str)
parser.add_argument('-c', '--chr', action="store", dest="chrom", help="chromosome number", default=None, type=int)
parser.add_argument('-o', '--out', action="store", dest="out_file", help="output file", default=None, type=str)
args = parser.parse_args()

def make_dframe(vcf):
    da = pd.DataFrame({
        'CHROM': vcf['variants/CHROM'],
        'POS': vcf['variants/POS'],
        'REF': vcf['variants/REF'],
        'ALT': vcf['variants/ALT'][:, 0]
    })
    return da

chrom_n = args.chrom
chrom = "chr"+str(chrom_n)

# read in VCFs
# MXB-imputed
MXB_imputed = allel.read_vcf(args.vcf_1)
# MXB-WGS
MXB_wgs = allel.read_vcf(args.vcf_2)

# genotypes are compared column by column, so both VCFs need the same samples in the same order
assert list(MXB_imputed['samples']) == list(MXB_wgs['samples']), "samples differ between VCFs"

# get shared positions
# make data frames
MXB_imputed_da = make_dframe(MXB_imputed)
MXB_wgs_da = make_dframe(MXB_wgs)
# shared sites based on being exact matches
intersection = pd.merge(MXB_imputed_da, MXB_wgs_da, how='inner', on=['CHROM', 'POS', 'REF', 'ALT'])
# re-merge to find the matching indices
# aka shared positions in MXB-WGS
MXB_wgs_da['index'] = MXB_wgs_da.index
merge_index = pd.merge(MXB_wgs_da, intersection, how='inner', on=['CHROM', 'POS', 'REF', 'ALT'])
index_to_keep = merge_index['index'].values

# GT
MXB_imputed_GT = allel.GenotypeArray(MXB_imputed['calldata/GT'])
# GT for shared variants only
MXB_WGS_GT = allel.GenotypeArray(MXB_wgs['calldata/GT'][index_to_keep])

# SNPs positions
positions = intersection["POS"]

# compute statistics
geno_corr = []
geno_concordance = []

for index in range(0, len(positions)):

    # allele dosages
    MXB_WGS_dosage = MXB_WGS_GT[index].to_n_alt()
    MXB_imputed_dosage = MXB_imputed_GT[index].to_n_alt()

    # Pearson's R between dosages
    geno_corr.append(np.corrcoef(MXB_WGS_dosage, MXB_imputed_dosage)[0, 1])

    # genotype concordance (phasing ignored)
    is_accurate = np.all(np.sort(MXB_WGS_GT[index], axis=1) == np.sort(MXB_imputed_GT[index], axis=1), axis=1)
    geno_concordance.append(np.mean(is_accurate))

imputed_sites_info = pd.read_csv(args.info_file, sep="\t", header=None)

if sum(imputed_sites_info[1] == positions) == len(positions):
    out = pd.DataFrame({
        'chrom': chrom,
        'pos': positions,
        'id': imputed_sites_info[4],
        'maf_in_MXB_imputed_all_samples': imputed_sites_info[10],
        'TYPE': imputed_sites_info[8],
        'R2_minimac4': imputed_sites_info[5],
        'corr': geno_corr,
        'geno_concordance': geno_concordance
    })
    out.to_csv(args.out_file, sep="\t", index=False)
    print("Successfully processed!")
else:
    print("Positions in the INFO file do not match the VCFs.")
