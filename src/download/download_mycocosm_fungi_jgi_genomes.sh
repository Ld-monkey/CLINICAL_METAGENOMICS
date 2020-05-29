#!/bin/bash

USERNAME=$1
PASSWORD=$2

# Activate conda environmnet.
conda activate metagenomic_env

# Add current time of database creation.
DATE=$(date +_%d_%m_%Y)

# All paths
PATH_MYCOCOSM_GENOME=../../data/raw_sequences/mycocosm_fungi_ncbi_CDS$DATE/
 
mkdir -p -v $PATH_MYCOCOSM_GENOME

echo "Download all mycocosm genome aka fungi from jgi."
MYCOCOSM_TYPE=fungi
python download_jgi_genomes.py -u $USERNAME -p $PASSWORD -db $MYCOCOSM_TYPE -out $PATH_MYCOCOSM_GENOME
echo "Download done !"

echo "Unzip all mycocosm genomes."
gunzip --verbose $PATH_MYCOCOSM_GENOME$MYCOCOSM_TYPE/*.gz
echo "Unzip done !"

echo "Add ncbi id taxonomy for all genome"
python ../python/jgi_id_to_ncbi_id_taxonomy.py -csv all_organisms.csv -path_sequence $PATH_MYCOCOSM_GENOME$MYCOCOSM_TYPE/
echo "Adding done !"

# Disable conda environment.
conda deactivate






