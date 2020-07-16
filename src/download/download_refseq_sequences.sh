#!/bin/bash

# download_refseq_sequences.sh is a shell script to download sequences from
# refseq database (Must have makemap.pl to recover fasta part).
#
# e.g bash src/download/download_refseq_sequences.sh

# Function to download viral refseq sequences.
function download_bacteria_sequences {

    # Full name of raw sequence folder.
    BACTERIA_OUTPUT=${OUTPUT_FOLDER}${DATE}/bacteria/

    # Create specific folder.
    mkdir -p --verbose $BACTERIA_OUTPUT

    echo "Download all bacterial sequences from RefSeq database."
    wget ftp://ftp.ncbi.nlm.nih.gov/refseq/release/bacteria/*genomic.gbff.gz \
         --directory-prefix=$BACTERIA_OUTPUT
    echo "Download done !"

    # Unzip archive.
    gunzip --keep $BACTERIA_OUTPUT*genomic.gbff.gz
    echo "Unzipped done !"

    # List all archives.
    archives_gbff=$(ls $BACTERIA_OUTPUT*genomic.gbff)
    echo $archives_gbff

    # Recover fasta part of file and stock taxonomics references.
    for file in ${archives_gbff};
    do
        perl src/download/makemap.pl $file
    done

    # Concatenate all sequences to one fasta file.
    cat $BACTERIA_OUTPUT*genomic.gbff.fa >> \
        ${BACTERIA_OUTPUT}all_genomic_viral_sequences.fasta
    echo "Concatenation of all bacteria sequences done !"
    echo "Output > all_genomic_bacteria_sequences.fasta"

    # Concatenate all .map to one map file completed.
    cat $BACTERIA_OUTPUT*genomic.gbff.map >> \
        ${BACTERIA_OUTPUT}viral_map.complete
    echo "Concatenation of all bacteria maps files done !"
    echo "Output > bactieria_map.complete"
    
}

# Function to download viral refseq sequences.
function download_viral_sequences {

    # Full name of raw sequence folder.
    VIRAL_OUTPUT=${OUTPUT_FOLDER}${DATE}/viral/

    # Create specific folder.
    mkdir -p --verbose $VIRAL_OUTPUT

    echo "Download all viral sequences from RefSeq database."
    # Link to download the all viral sequence from refseq database.
    wget ftp://ftp.ncbi.nlm.nih.gov/refseq/release/viral/*genomic.gbff.gz \
         --directory-prefix=$VIRAL_OUTPUT
    echo "Download done !"

    # Unzip archive.
    gunzip --keep $VIRAL_OUTPUT*genomic.gbff.gz
    echo "Unzipped done !"

    # List all archives.
    archives_gbff=$(ls $VIRAL_OUTPUT*genomic.gbff)
    echo $archives_gbff

    # Recover fasta part of file and stock taxonomics references.
    for file in ${archives_gbff};
    do
        perl src/download/makemap.pl $file
    done

    # Concatenate all sequences to one fasta file.
    cat $VIRAL_OUTPUT*genomic.gbff.fa >> \
        ${VIRAL_OUTPUT}all_genomic_viral_sequences.fasta
    echo "Concatenation of all viral sequences done !"
    echo "Output > all_genomic_viral_sequences.fasta"

    # Concatenate all .map to one map file completed.
    cat $VIRAL_OUTPUT*genomic.gbff.map >> ${VIRAL_OUTPUT}viral_map.complete
    echo "Concatenation of all viral maps files done !"
    echo "Output > viral_map.complete"
}


# Function to check the correct -type_db parameter.
function check_type_and_download_database {
    for TYPE in ${TYPE_DATABASE}; do
        if [[ $TYPE = "bacteria" ]]  ||  [[ $TYPE = "viral" ]]
        then
            echo "Correct parameter -type_db $TYPE"
            case $TYPE in
                bacteria)
                    echo "*   bacteria: RefSeq complete bacterial genomes"

                    # Download bacteria sequences.
                    download_bacteria_sequences
                    ;;
                viral)
                    echo "*   viral: RefSeq complete viral genomes"

                    # Download viral sequences.
                    download_viral_sequences
                    ;;            
            esac
        else
            echo "-type_db parameter doesn't correspond to following list :"
            echo -e "
           *   bacteria: RefSeq complete bacterial genomes/proteins
           *   viral: RefSeq complete viral genomes/proteins
           "
            echo "Error in -type parameter"

            exit 1
        fi
    done
}


PROGRAM=download_refseq_sequences.sh
VERSION=1.0

DESCRIPTION=$(cat << __DESCRIPTION__

__DESCRIPTION__
           )

OPTIONS=$(cat << __OPTIONS__

## OPTIONS ##
    -type_db         (Input) Which reference librairie for database (choices: viral, bacteria, human)          *STR: viral
    -path_output     (Output) The folder of refseq output                                                      *DIR: data/raw_sequences/viral_refseq/
__OPTIONS__
       )

# default options:

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
    echo  "e.g : bash src/download/download_refseq_viral_sequences.sh"
    echo -e $USAGE

    exit 1
}

# Check options
while [ -n "$1" ]; do
    case $1 in
        -h)                    USAGE      ; exit 0 ;;
        -type_db)              TYPE_DATABASE=$2    ; shift 2; continue ;;
        -path_output)          OUTPUT_FOLDER=$2    ; shift 2; continue ;;
        *)       BAD_OPTION $1;;
    esac
done

# Add current time of database creation.
DATE=$(date +_%d_%m_%Y)

# Check correct parameter and download refseq sequences.
check_type_and_download_database
