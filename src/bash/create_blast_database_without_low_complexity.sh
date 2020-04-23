#!/bin/bash

# With all the raw sequences download with ncbi or with the python
# script get_database_from_accession_list.py we create a single file
# which brings together all the sequences in fna format.
# Then we use the dustmasker software to remove sequences of low complexity.
# Finally we create a database that can be used by blast software with makeblastdb.

# e.g create_blast_database_without_low_complexity.sh \
#    -path_seqs test_database_blast/ \
#    -output_fasta output_multi_fasta \
#    -name_db database_test

PROGRAM=create_blast_database_without_low_complexity.sh
VERSION=1.0

DESCRIPTION=$(cat << __DESCRIPTION__

__DESCRIPTION__
           )

OPTIONS=$(cat << __OPTIONS__

## OPTIONS ##
    -path_seqs       (Input)  The path of all sequences to create database.                                *DIR: all_sequences
    -output_fasta    (Output) The output file containt all sequences.                                      *FILE: output_sequences
    -name_db         (Input/Output)  The name of database.                                                 *DIR: 16S_database
__OPTIONS__
       )

# default options if they are not defined:
name_db=database_output

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
    echo "e.g create_blast_database_without_low_complexity.sh -path_seqs test_database_blast/ -output_fasta output_multi_fasta -name_db database_test"
    echo -e $USAGE

    exit 1
}

# Check options
while [ -n "$1" ]; do
    case $1 in
        -h)                    USAGE      ; exit 0 ;;
        -path_seqs)            PATH_RAW_FASTA_FILE=$2         ; shift 2; continue ;;
  	    -output_fasta)         BASENAME_OUTPUT_MULTI_FASTA=$2 ; shift 2; continue ;;
        -name_db)              NAME_DATABASE=$2               ; shift 2; continue ;;
        *)       BAD_OPTION $1;;
    esac
done

# Check if the multiple fasta file is already created.
if [ -s $PATH_RAW_FASTA_FILE$BASENAME_OUTPUT_MULTI_FASTA.fa ]
then
    echo "The file $PATH_RAW_FASTA_FILE$BASENAME_OUTPUT_MULTI_FASTA.fa already exist."
else
    # Create a unique multi fasta file with .fsa extention
    for fasta_file in $PATH_RAW_FASTA_FILE*.fna
    do
        echo "$fasta_file is added"
        cat $fasta_file >> $PATH_RAW_FASTA_FILE$BASENAME_OUTPUT_MULTI_FASTA.fa
    done
fi

# Check if the folder DUSTMASKER_$NAME_DATABASE exists.
if [ -d ${PATH_RAW_FASTA_FILE}DUSTMASKER_$NAME_DATABASE ]
then
    echo "The folder DUSTMASKER_$NAME_DATABASE already exists."
else
    echo "Create DUSTMASKER_$NAME_DATABASE."
    mkdir ${PATH_RAW_FASTA_FILE}DUSTMASKER_$NAME_DATABASE
    echo "Create DUSTMASKER_$NAME_DATABASE done."
fi
# Check if in the folder dustmasker there is dustmasker.asnb.
if [ -s ${PATH_RAW_FASTA_FILE}DUSTMASKER_$NAME_DATABASE/dustmasker.asnb ]
then
    echo "The dustmasker file already exists for the database."
else
    echo "Remove low complexity."
    # Remove low complexity with dustmasker only for nucleotide.
    dustmasker -in $PATH_RAW_FASTA_FILE$BASENAME_OUTPUT_MULTI_FASTA.fa \
               -infmt fasta -parse_seqids -outfmt maskinfo_asn1_bin \
               -out ${PATH_RAW_FASTA_FILE}DUSTMASKER_$NAME_DATABASE/dustmasker.asnb
    echo "Low complexity done."
fi

# Check if the database already exists.
if [ -d ${PATH_RAW_FASTA_FILE}MAKEBLAST_$NAME_DATABASE ]
then
    echo "The folder MAKEBLAST_$NAME_DATABASE already exists."
    echo "In this case, the database : $NAME_DATABASE already exists"
else
    echo "Create the folder MAKEBLAST_$NAME_DATABASE"
    mkdir ${PATH_RAW_FASTA_FILE}MAKEBLAST_$NAME_DATABASE
    echo "Folder done"

    # Create a simple custom database from a multi-fasta file.
    echo "Create database."
    echo "$PATH_RAW_FASTA_FILE$BASENAME_OUTPUT_MULTI_FASTA.fa"

    # Create database with makeblastdb.
    makeblastdb -in $PATH_RAW_FASTA_FILE$BASENAME_OUTPUT_MULTI_FASTA.fa \
                -dbtype nucl \
                -parse_seqids \
                -mask_data ${PATH_RAW_FASTA_FILE}DUSTMASKER_$NAME_DATABASE/dustmasker.asnb \
                -out $PATH_RAW_FASTA_FILE$NAME_DATABASE \
                -title "Database with makeblastdb"
    echo "Database done."

    # Move all files of the database in the folder.
    mv $PATH_RAW_FASTA_FILE$NAME_DATABASE.n* ${PATH_RAW_FASTA_FILE}MAKEBLAST_$NAME_DATABASE/

    echo "All file are moved in ${PATH_RAW_FASTA_FILE}MAKEBLAST_$NAME_DATABASE"
fi

# Print a summary of the target database in README.txt .
blastdbcmd -db ${PATH_RAW_FASTA_FILE}MAKEBLAST_$NAME_DATABASE/$NAME_DATABASE -info \
           > ${PATH_RAW_FASTA_FILE}MAKEBLAST_$NAME_DATABASE/README.txt

# Deactivate module.
module unload blastplus/2.2.31
