#!/bin/bash

# Path variable to data folder.
PATH_DATA=../../data/raw_sequences

# Add current time of database creation.
DATE=$(date +_%d_%m_%Y)

# Full name of raw sequence folder.
BASENAME_DB=bacteria_sequences_from_refseq$DATE

echo $BASENAME_DB

# Enable conda environment
conda activate metagenomic_env

echo "Download all bacterial sequences from RefSeq database."

# Create specific folder.
mkdir -p -v $PATH_DATA/$BASENAME_DB

# Unzip archive and keep the original zip.
tar -xvf $PATH_DATA/$BASENAME_DB/*.tar --directory $PATH_DATA/$BASENAME_DB/
echo "Unzipped done !"

Unzip archive.
gunzip --keep $PATH_DATA/$BASENAME_DB/*genomic.gbff.gz
echo "Unzipped done !"

# List all archives.
archives_gbff=$(ls $PATH_DATA/$BASENAME_DB/*genomic.gbff)
echo "Unzipped done !"

# Recover specific part of file.
for file in ${archives_gbff};
do
    perl makemap.pl $file
done

# Add all .fa sequences to one fasta file.
cat $PATH_DATA/$BASENAME_DB/*.gbff.fa >> $PATH_DATA/$BASENAME_DB/all_genomic_bacteria_sequences.fasta
echo "Bacteria sequence done !"

# Add all .map to one map file completed.
cat $PATH_DATA/$BASENAME_DB/*.gbff.map >> $PATH_DATA/$BASENAME_DB/bacteria_map.complete
echo "Bacteria map file done !"

rm -v $PATH_DATA/$BASENAME_DB/*.gbff
rm -v $PATH_DATA/$BASENAME_DB/*gbff.map
rm -v $PATH_DATA/$BASENAME_DB/*gbff.gz

# Disable conda environment.
conda deactivate
