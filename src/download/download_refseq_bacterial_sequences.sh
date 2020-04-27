#!/bin/bash

# Path variable to data folder.
PATH_DATA=../../data/raw_sequences
BASENAME_DB=bacterial_sequences_from_refseq

# Enable conda environment
conda active metagenomic_env


echo "Download all bacterial sequences from RefSeq database."

# Create specific folder.
mkdir $PATH_DATA/$BASENAME_DB


gunzip *gz

#change directory

gbff=${ls *gbff}
for gbffFile in ${gbff};
do
    ./makemap.pl $fungigbffFile
done
cat *gbff.fa >> bacteria.genomic.fa
cat *gbff.map >> map.complete
rm *gbff.fa *gbff.map *gbff
makeblastdb -in bacteria.genomic.fasta -parse_seqids -dbtype nucl -title RefSeqBacteria -taxid_map map.complete
conda deactivate
