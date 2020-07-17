#!/bin/bash

# With all the raw sequences download with ncbi or with the python
# script get_database_from_accession_list.py we create a single file
# which brings together all the sequences in fna format.
# Then we use the dustmasker software to remove sequences of low complexity.
# Finally we create a database that can be used by blast software with makeblastdb.

# e.g create_blast_database_without_low_complexity.sh \
#    -path_seq test_database_blast/ \
#    -output_db output_multi_fasta \
#    -name_db database_test


# Function to check if the sequence folder exists.
function check_sequence_folder {

    #Check if parameter is set.
    if [ -z ${PATH_SEQUENCES+x} ]
    then
        echo "-path_seq unset."
        echo "Error ! No others sequence will be added to the blast database."

        # Quit program.
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


# Function to check the correct format of sequences.
function concatenate_sequences {
    if [ ${SEQUENCE: -3} == ".gz" ]
    then
        # Zip concatenation.
        gzip -c $SEQUENCE >> $OUTPUT_DATABASE${DEFAULT_NAME_CONCATENATION}gz
    else
        # Other format concatenation (.fasta, .fastq, .fna).
        cat $SEQUENCE >> $OUTPUT_DATABASE${DEFAULT_NAME_CONCATENATION}$EXTENSION
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
    -name_db   (Input/Output)  The name of database.                                                 *DIR: 16S_database
    -force_remove (Optional) Change the default parameter the deletion of intermediate files.        *STR: (yes|no)
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
    echo "e.g bash/src/bash/create_blast_database_without_low_complexity.sh -path_seq test_database_blast/ -output_db output_multi_fasta -name_db database_test"
    echo -e $USAGE

    exit 1
}

# Check options
while [ -n "$1" ]; do
    case $1 in
        -h)                   USAGE      ; exit 0 ;;
        -path_seq)            PATH_SEQUENCES=$2         ; shift 2; continue ;;
  	    -output_db)           OUTPUT_DATABASE=$2        ; shift 2; continue ;;
        -name_db)             NAME_DATABASE=$2          ; shift 2; continue ;;
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
    EXTENSION="${SEQUENCE#.*}"
    echo "extension : $EXTENSION"
    concatenate_sequences
done

# Check if zipped file .gz
if [ $(ls $OUTPUT_DATABASE$DEFAULT_NAME_CONCATENATION: -3) == ".gz" ]; then
    echo "Zipped concatenate file."
    gunzip -v $(ls $OUTPUT_DATABASE$DEFAULT_NAME_CONCATENATION)
fi

# Create a folder for dustermasker

# Remove low complexity into sequences with dustmasker.

# Create database with makeblastdb.

# Print a summary of the target database in README.txt

# Remove intermediate files as (concatenate, dustmaske folder)


# Check if the multiple fasta file is already created.
# if [ -s $PATH_SEQUENCES$OUTPUT_DATABASE.fa ]
# then
#     echo "The file $PATH_SEQUENCES$OUTPUT_DATABASE.fa already exist."
# else
#     # Create a unique multi fasta file with .fsa extention
#     for fasta_file in $PATH_SEQUENCES*.fna
#     do
#         echo "$fasta_file is added"
#         cat $fasta_file >> $PATH_SEQUENCES$OUTPUT_DATABASE.fa
#     done
# fi

# # Check if the folder DUSTMASKER_$NAME_DATABASE exists.
# if [ -d ${PATH_SEQUENCES}DUSTMASKER_$NAME_DATABASE ]
# then
#     echo "The folder DUSTMASKER_$NAME_DATABASE already exists."
# else
#     echo "Create DUSTMASKER_$NAME_DATABASE."
#     mkdir ${PATH_SEQUENCES}DUSTMASKER_$NAME_DATABASE
#     echo "Create DUSTMASKER_$NAME_DATABASE done."
# fi
# # Check if in the folder dustmasker there is dustmasker.asnb.
# if [ -s ${PATH_SEQUENCES}DUSTMASKER_$NAME_DATABASE/dustmasker.asnb ]
# then
#     echo "The dustmasker file already exists for the database."
# else
#     echo "Remove low complexity."
#     # Remove low complexity with dustmasker only for nucleotide.
#     dustmasker -in $PATH_SEQUENCES$OUTPUT_DATABASE.fa \
#                -infmt fasta -parse_seqids -outfmt maskinfo_asn1_bin \
#                -out ${PATH_SEQUENCES}DUSTMASKER_$NAME_DATABASE/dustmasker.asnb
#     echo "Low complexity done."
# fi

# # Check if the database already exists.
# if [ -d ${PATH_SEQUENCES}MAKEBLAST_$NAME_DATABASE ]
# then
#     echo "The folder MAKEBLAST_$NAME_DATABASE already exists."
#     echo "In this case, the database : $NAME_DATABASE already exists"
# else
#     echo "Create the folder MAKEBLAST_$NAME_DATABASE"
#     mkdir ${PATH_SEQUENCES}MAKEBLAST_$NAME_DATABASE
#     echo "Folder done"

#     # Create a simple custom database from a multi-fasta file.
#     echo "Create database."
#     echo "$PATH_SEQUENCES$OUTPUT_DATABASE.fa"

#     # Create database with makeblastdb.
#     makeblastdb -in $PATH_SEQUENCES$OUTPUT_DATABASE.fa \
#                 -dbtype nucl \
#                 -parse_seqids \
#                 -mask_data ${PATH_SEQUENCES}DUSTMASKER_$NAME_DATABASE/dustmasker.asnb \
#                 -out $PATH_SEQUENCES$NAME_DATABASE \
#                 -title "Database with makeblastdb"
#     echo "Database done."

#     # Move all files of the database in the folder.
#     mv $PATH_SEQUENCES$NAME_DATABASE.n* ${PATH_SEQUENCES}MAKEBLAST_$NAME_DATABASE/

#     echo "All file are moved in ${PATH_SEQUENCES}MAKEBLAST_$NAME_DATABASE"
# fi

# # Print a summary of the target database in README.txt .
# blastdbcmd -db ${PATH_SEQUENCES}MAKEBLAST_$NAME_DATABASE/$NAME_DATABASE -info \
#            > ${PATH_SEQUENCES}MAKEBLAST_$NAME_DATABASE/README.txt
