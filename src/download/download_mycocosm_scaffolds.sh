#!/bin/bash

USERNAME=$1
PASSWORD=$2
PATH_MYCOCOSM_GENOME=$3

echo $USERNAME
echo $PASSWORD
 
mkdir -p -v $PATH_MYCOCOSM_GENOME

echo "Download all mycocosm scaffolds aka fungi from JGI https://mycocosm.jgi.doe.gov/mycocosm/home"

# Define the type of database.
MYCOCOSM_TYPE=fungi

# Dowload all scaffolds from mycocosm database.
python src/download/download_scaffold_mycocosm_jgi.py \
       -u $USERNAME \
       -p $PASSWORD \
       -db $MYCOCOSM_TYPE \
       -out $PATH_MYCOCOSM_GENOME

echo "Download done !"

rm --verbose cookies

# Move the xml file in data/assembly .
mv --verbose fungi_files.xml data/assembly/

# Move the csv file in raw_sequences directory.
mv --verbose all_organisms.csv $PATH_MYCOCOSM_GENOME

echo "Unzip all mycocosm scaffolds."
gunzip --verbose $PATH_MYCOCOSM_GENOME$MYCOCOSM_TYPE/*.gz
echo "Unzip done !"

# echo "Add ncbi id taxonomy for all genome"
# python src/python/jgi_id_to_ncbi_id_taxonomy.py \
#        -csv ${PATH_MYCOCOSM_GENOME}all_organisms.csv \
#        -path_sequence $PATH_MYCOCOSM_GENOME$MYCOCOSM_TYPE/
# echo "Adding done !"

# echo "Move csv fungi output"
# mv --verbose output_fungi_csv.csv $PATH_MYCOCOSM_GENOME
# echo "Move done !"

# echo "Move impossible opening file"
# mv --verbose impossible_opening.txt $PATH_MYCOCOSM_GENOME
# echo "Move done !
