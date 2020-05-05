#!/bin/bash

# Activate conda environmnet.
conda activate metagenomic_env

# Add current time of database creation.
DATE=$(date +_%d_%m_%Y)

# All paths
PATH_NCBI_TAXA=../../data/databases/ete3_ncbi_taxanomy_database$DATE/
DEFAULT_ETE3_TAXA=~/.etetoolkit/*

mkdir -p -v $PATH_NCBI_TAXA

echo "Download ncbi taxonomy database."
python ../python/get_ete3_ncbi_taxa_db.py
echo "Download done !"

# Copy database.
cp --verbose $DEFAULT_ETE3_TAXA $PATH_NCBI_TAXA

rm --verbose taxdump.tar.gz

# Disable conda environment.
conda deactivate
