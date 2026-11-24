# archaic_tracts/hmmix

Archaic tract calling with hmmix (https://github.com/LauritsSkov/Introgression-detection), run on the Brown University Oscar cluster (SLURM). Paths at the top of each script are placeholders.

hmmix helpfiles for GRCh38 (callability mask, mutation rates, 1KGP + HGDP outgroup, ancestral sequence and high-coverage archaic variants) were downloaded from https://zenodo.org/records/11212339.

| Step | Script | Run as |
|---|---|---|
| 1 | `01.run_ingroup_train_decode.sh` | `sbatch --array=1-n_individuals 01.run_ingroup_train_decode.sh <sample_file> <name> <vcfs>` |

For each individual: create_ingroup, train a haploid model, decode the autosomes, then decode again with the archaic genomes (`-admixpop`) to annotate each tract.

Input VCFs: TODO (MXB-WGS / MXB-imputed).

## Software

hmmix (TODO: version), bcftools, vcftools.
