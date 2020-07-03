#!/bin/bash


USERNAME=$1
PASSWORD=$2
PATH_MYCOCOSM_GENOME=$3

echo $USERNAME
echo $PASSWORD
 
mkdir -p -v $PATH_MYCOCOSM_GENOME

echo "Download all mycocosm genome aka fungi from jgi."

# Define the type of database.
MYCOCOSM_TYPE=fungi

python src/download/download_jgi_genomes.py \
       -u $USERNAME \
       -p $PASSWORD \
       -db $MYCOCOSM_TYPE \
       -out $PATH_MYCOCOSM_GENOME

echo "Download done !"


rm --verbose cookies

# Move the xml file in data/assembly .
mv --verbose fungi_files.xml data/assembly/

# Move the csv file in raw_sequences directory.
mv --verbvose all_organisms.csv $PATH_MYCOCOSM_GENOME

echo "Unzip all mycocosm genomes."
gunzip --verbose $PATH_MYCOCOSM_GENOME$MYCOCOSM_TYPE/*.gz
echo "Unzip done !"

echo "Add ncbi id taxonomy for all genome"
python src/python/jgi_id_to_ncbi_id_taxonomy.py \
       -csv ${PATH_MYCOCOSM_GENOME}all_organisms.csv \
       -path_sequence $PATH_MYCOCOSM_GENOME$MYCOCOSM_TYPE/
echo "Adding done !"
