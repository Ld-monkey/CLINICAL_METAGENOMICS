#!/bin/bash

# Download all scaffolds of mycocosm and add correct description and
# ncbi taxonomy to sequences.
# e.g bash src/download/download_mycocosm_scaffolds.sh \
#          -username your_username \
#          -password your_password \
#          -path_output data/raw_sequences/mycocosm_fungi_ncbi_scaffold_08_07_2020/

PROGRAM=download_mycocosm_scaffolds.sh
VERSION=1.0

DESCRIPTION=$(cat << __DESCRIPTION__

__DESCRIPTION__
           )

OPTIONS=$(cat << __OPTIONS__

## OPTIONS ##
    -username    (input)  Your username in mycocosm plateform.                   *STR: username
    -password    (input)  Your password in mycocosm plateform.                   *STR: password
    -path_output (output) The folder of output.                                  *DIR: data/raw_sequences/mycocosm/
__OPTIONS__
       )

# default options if they are not defined:

USAGE ()
{
    cat << __USAGE__
$PROGRAM version $VERSION:
$DESCRIPTION
$OPTIONS

__USAGE__
}

BAD_OPTION ()
{
    echo
    echo "Unknown option "$1" found on command-line"
    echo "It may be a good idea to read the usage:"
    echo "white $PROGRAM -h to be helped :"
    echo "example : bash src/download/download_mycocosm_scaffolds.sh -username your_username -password your_password -path_output data/raw_sequences/mycocosm_fungi_ncbi_scaffold_08_07_2020/"
    echo -e $USAGE

    exit 1
}

# Check options
while [ -n "$1" ]; do
    case $1 in
        -h)                    USAGE      ; exit 0 ;;
        -username)         USERNAME=$2                ; shift 2; continue ;;
        -password)         PASSWORD=$2                ; shift 2; continue ;;
        -path_output)      PATH_MYCOCOSM_GENOME=$2    ; shift 2; continue ;;
        *)       BAD_OPTION $1;;
    esac
done

echo $USERNAME
echo $PASSWORD
echo $PATH_MYCOCOSM_GENOME
 
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
