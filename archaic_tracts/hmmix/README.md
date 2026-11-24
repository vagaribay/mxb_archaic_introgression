Archaic tract calling with hmmix (https://github.com/LauritsSkov/Introgression-detection), run on the Brown University Oscar cluster (SLURM). Paths at the top of each script are placeholders.

hmmix helpfiles for GRCh38 (callability mask, mutation rates, 1KGP + HGDP outgroup, ancestral sequence and high-coverage archaic variants) were downloaded from https://zenodo.org/records/11212339.

For each individual: create_ingroup, train a haploid model, decode the autosomes, then decode again with the archaic genomes (`-admixpop`) to annotate each tract.

Input VCFs: both MXB-WGS / MXB-imputed.
