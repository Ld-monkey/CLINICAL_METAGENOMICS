#!/bin/bash

# Path variable to data folder.
PATH_DATA=../../data/raw_sequences
BASENAME_DB=bacterial_sequences_from_refseq

# Enable conda environment
conda activate metagenomic_env

echo "Download all bacterial sequences from RefSeq database."

# Create specific folder.
mkdir -p -v $PATH_DATA/$BASENAME_DB

# Unzip archive.
gunzip $PATH_DATA/$BASENAME_DB/*gz
echo "Unzipped done !"

# List all archives.
archives_gbff=${ls $PATH_DATA/$BASENAME_DB/*.gbff.gz}
echo "Unzipped done !"

# Recover specific part of file.
for file in ${archives_gbff};
do
    ./makemap.pl $file
done

# Add all .fa sequences to one fasta file.
cat $PATH_DATA/$BASENAME_DB/*.gbff.fa >> $PATH_DATA/$BASENAME_DB/all_genomic_bacterial_sequences.fasta
echo "Bacteria sequence done !"

# Add all .map to one map file completed.
cat $PATH_DATA/$BASENAME_DB/*.gbff.map >> $PATH_DATA/$BASENAME_DB/bacterial_map.complete
echo "Bacterial map file done !"

# Disable conda environment.
conda deactivate
