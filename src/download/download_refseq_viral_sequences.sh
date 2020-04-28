#!/bin/bash

# Path variable to data folder.
PATH_DATA=../../data/raw_sequences
BASENAME_DB=viral_sequences_from_refseq

# Enable conda environment
conda active metagenomic_env

echo "Download all viral sequences from RefSeq database."

# Create specific folder.
mkdir $PATH_DATA/$BASENAME_DB

# Link to download the all viral sequence from refseq database.
wget ftp://ftp.ncbi.nlm.nih.gov/refseq/release/viral/*genomic.gbff.gz \
     --directory-prefix=$PATH_DATA/$BASENAME_DB/
echo "Download done !"

# Unzip archive.
gunzip $PATH_DATA/$BASENAME_DB/*genomic.gbff.gz
echo "Unzipped done !"

# List all archives.
archives_gbff=${ls $PATH_DATA/$BASENAME_DB/*genomic.gbff}

# Recover specific part of file.
for file in ${archives_gbff};
do
    ./makemap.pl $file
done

# Add all .fa sequences to one fasta file.
cat $PATH_DATA/$BASENAME_DB/*genomic.gbff.fa >> $PATH_DATA/$BASENAME_DB/all_genomic_viral_sequences.fasta
echo "Viral sequence done !"

# Add all .map to one map file completed.
cat $PATH_DATA/$BASENAME_DB/*genomic.gbff.map >> $PATH_DATA/$BASENAME_DB/viral_map.complete
echo "Viral map file done !"

# Disable conda environment.
conda deactivate
