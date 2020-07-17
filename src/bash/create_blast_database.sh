#!/bin/bash

# Create a local database that can be used by blast software.
#
# e.g bash src/create_blast_database \
#              -path_seq data/raw_sequences/refseq/bacteria/ \
#              -output_db data/databases/blast/refseq/


# Function to check if the sequence folder exists.
function check_sequence_folder {

    #Check if parameter is set.
    if [ -z ${PATH_SEQUENCES+x} ]
    then
        echo "-path_seq unset."
        echo "Error ! No others sequence will be added to the blast database."
        exit
    else
        if [ -d ${PATH_SEQUENCES} ]
        then
            echo $PATH_SEQUENCES
            echo "$PATH_SEQUENCES folder of sequence exist."
        else
            echo "Error $PATH_SEQUENCES doesn't exist."
            exit
        fi
    fi
}


# Function to check if the database folder exists.
function check_output_database_folder {
    if [ -d $OUTPUT_DATABASE ]
    then
        echo "$OUTPUT_DATABASE folder already exits."
    else
        mkdir -p --verbose $OUTPUT_DATABASE
        echo "Create folder database $OUTPUT_DATABASE "
    fi
}


# Function to concatenate the correct format of sequences.
function concatenate_sequences {
    if [ ${SEQUENCE: -3} == ".gz" ]
    then
        # Zip concatenation.
        cat $SEQUENCE >> $OUTPUT_DATABASE${DEFAULT_NAME_CONCATENATION}gz
    else
        # Other format concatenation (.fasta, .fastq, .fna) -> fasta
        cat $SEQUENCE >> $OUTPUT_DATABASE${DEFAULT_NAME_CONCATENATION}fasta
    fi
}


# Create specific folder for dustmasker use.
function create_dustmasker_folder {
    # Check if the folder ${OUTPUT_DATABASE}dustmasker exists.
    if [ -d ${OUTPUT_DATABASE}dustmasker ]
    then
        echo "The folder ${OUTPUT_DATABASE}dustmasker already exists."
    else
        echo "Create ${OUTPUT_DATABASE}dustmasker"
        mkdir -p --verbose ${OUTPUT_DATABASE}dustmasker/
    fi
}


# Run dustmasker and remove low complexity in sequences.
function run_dustmasker {    
    # Check if in the folder dustmasker there is dustmasker.asnb.
    if [ -s ${OUTPUT_DATABASE}dustmasker/dustmasker.asnb ]
    then
        echo "The dustmasker file already exists for the database."
    else
        echo "Remove low complexity."

        # Remove low complexity with dustmasker (only for nucleotide).
        dustmasker -in ${OUTPUT_DATABASE}${DEFAULT_NAME_CONCATENATION}fasta \
                   -infmt fasta \
                   -parse_seqids \
                   -outfmt maskinfo_asn1_bin \
                   -out ${OUTPUT_DATABASE}dustmasker/dustmasker.asnb
        echo "Remove low complexity done."
    fi    

}

# Run makeblastdb to create local blast database.
function run_makeblastdb {
    echo "Creation of a local blast database"

    echo "-out $OUTPUT_DATABASE"

    if [[ $DUSTMASKER_FLAG == "yes" ]]
    then
        # Create database with makeblastdb without low complexity sequences.
        makeblastdb -in ${OUTPUT_DATABASE}${DEFAULT_NAME_CONCATENATION}fasta \
                    -dbtype nucl \
                    -parse_seqids \
                    -mask_data ${OUTPUT_DATABASE}dustmasker/dustmasker.asnb \
                    -out ${OUTPUT_DATABASE}/makeblastdb \
                    -title "Blast database without low complexity sequences"
        echo "Database done."
    else
        # Create database with makeblastdb with low complexity sequences.
        makeblastdb -in ${OUTPUT_DATABASE}${DEFAULT_NAME_CONCATENATION}fasta \
                    -dbtype nucl \
                    -parse_seqids \
                    -out ${OUTPUT_DATABASE}/makeblastdb \
                    -title "Blast database with low complexity sequences"
    fi
}


# Make a summary on created database.
function make_database_summary {
    # Print a summary of the target database in README.txt .
    blastdbcmd -db ${OUTPUT_DATABASE}makeblastdb -info \
               > ${OUTPUT_DATABASE}/README.txt

    echo "Summary done !"
}


# Remove intermediate files.
function remove_intermediate_files {
    if [[ $FORCE_REMOVE == "yes" ]]
    then
        echo "Delete intermediate files"
        rm -rf --verbose ${OUTPUT_DATABASE}dustmasker
        rm -rf --verbose ${OUTPUT_DATABASE}*.fasta
        rm -rf --verbose ${OUTPUT_DATABASE}*.fastq
        rm -rf --verbose ${OUTPUT_DATABASE}*.fna
        rm -rf --verbose ${OUTPUT_DATABASE}*.gz
        echo "Remove done !"
    else
        echo "We don't delete intermediate files !"
    fi    
}


PROGRAM=create_blast_database.sh
VERSION=1.0

DESCRIPTION=$(cat << __DESCRIPTION__

__DESCRIPTION__
           )

OPTIONS=$(cat << __OPTIONS__

## OPTIONS ##
    -path_seq  (Input)  The path of all sequences to create database.                                *DIR: all_sequences
    -output_db (Output) The output file containt all sequences.                                      *FILE: output_sequences
    -dustmasker (Optional) Applied dustmasker or not to remove low complexity sequences.             *STR: (yes|no)
    -force_remove (Optional) Change the default parameter the deletion of intermediate files.        *STR: (yes|no)
__OPTIONS__
       )

# Default options if they are not defined:
FORCE_REMOVE=yes
DUSTMASKER_FLAG=yes

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
    echo "e.g bash src/create_blast_database -path_seq data/raw_sequences/refseq/bacteria/ -output_db data/databases/blast/refseq/ "
    echo -e $USAGE

    exit 1
}

# Check options
while [ -n "$1" ]; do
    case $1 in
        -h)                   USAGE      ; exit 0 ;;
        -path_seq)            PATH_SEQUENCES=$2         ; shift 2; continue ;;
  	    -output_db)           OUTPUT_DATABASE=$2        ; shift 2; continue ;;
        -dustmasker)          DUSTMASKER_FLAG=$2        ; shift 2; continue ;;
        -force_remove)        FORCE_REMOVE=$2           ; shift 2; continue ;;
        *)       BAD_OPTION $1;;
    esac
done

# Check if sequences exists.
check_sequence_folder

# Check if output folder exists.
check_output_database_folder

# Get extension of sequences.
DEFAULT_NAME_CONCATENATION="final_sequences."

# Concatenate sequences.
for SEQUENCE in ${PATH_SEQUENCES}*; do
    concatenate_sequences
done

echo "Concatenation done !"

# Get output of concatenation.
OUTPUT_CONCATENATION=$(ls $OUTPUT_DATABASE${DEFAULT_NAME_CONCATENATION}*)

# Check if zipped file .gz
if [ ${OUTPUT_CONCATENATION: -3} == ".gz" ]; then
    BASENAME=$(basename "$OUTPUT_CONCATENATION" .gz)
    gunzip -c $OUTPUT_CONCATENATION > ${OUTPUT_DATABASE}${BASENAME}.fasta
    echo "Unzip done !"
fi

# If dustmasker is used.
if [[ $DUSTMASKER_FLAG == "yes" ]]
then
    # Create a folder for dustmasker.
    create_dustmasker_folder

    # Remove low complexity in sequences with dustmasker.
    run_dustmasker
else
    echo "$DUSTMASKER_FLAG is not yes"
    echo "Dustmasker will not be applied"
fi

# Create database with makeblastdb.
run_makeblastdb

# Print a summary of the target database in README.txt
make_database_summary

# Remove intermediate files as (concatenate, dustmaske folder)
# By default delete intermediate (dedupe) file.
remove_intermediate_files
