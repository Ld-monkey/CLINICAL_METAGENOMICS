#!/bin/bash

# Download all data from fungi db.
# e.g bash src/download/download_fungi_db.sh \
#          -path_output data/raw_sequences/fungi_db_all_genomes_06_07_2020/

PROGRAM=download_fungi_db.sh
VERSION=1.0

DESCRIPTION=$(cat << __DESCRIPTION__

__DESCRIPTION__
           )

OPTIONS=$(cat << __OPTIONS__

## OPTIONS ##
    -path_output     (output) The folder of output                               *DIR: output_database/
__OPTIONS__
       )

# default options if they are not defined:
OUTPUT_FOLDER=.

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
    echo "example : bash src/download/download_fungi_db.sh -path_output data/raw_sequences/fungi_db_all_genomes_06_07_2020/"
    echo -e $USAGE

    exit 1
}

# Check options
while [ -n "$1" ]; do
    case $1 in
        -h)                    USAGE      ; exit 0 ;;
        -path_output)          OUTPUT_FOLDER=$2    ; shift 2; continue ;;
        *)       BAD_OPTION $1;;
    esac
done

echo "Download Fungi DB from https://fungidb.org/common/downloads/"

# Download release of Fungi DB
wget --verbose https://fungidb.org/common/downloads/release-3.0.tar

echo "Download Fungi DB done !"

# Create output folder if doesn't exists.
mkdir -v $OUTPUT_FOLDER
echo "Create output folder done !"

# Unzip realease in specific folder.
echo "Unzip tar in $OUTPUT_FOLDER"
tar -xvf release-3.0.tar --directory $OUTPUT_FOLDER

# Recover complete genome in all Fungi DB librairy.
echo "Find the complete genome and copy in output folder"
find $OUTPUT_FOLDER -name "*Genome.fasta.gz*" -print0 \
    | xargs -0 -I{} cp {} --verbose --target-directory=$OUTPUT_FOLDER
echo "Complete genome done !"

# Unzip all complete genome.
gunzip --verbose $OUTPUT_FOLDER/*.gz
echo "Unzip done !"
