#!/bin/bash

# Try to find same taxonomic id between Kraken 2 and Blast.
#
# e.g bash/src/
#

# blast file

# Output files is conserved and not_conserved ID of taxa from blast.txt .
python3 ../python/sort_blasted_seq.py \
        -i ${BLAST_FOLDER}/$interest_blast \
        -o ${basename_}conserved.txt \
        -n ${PATH_NCBI_TAXA}/taxa.sqlite

