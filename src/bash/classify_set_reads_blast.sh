#!/bin/bash

# From a set of reads and depend of the database gived in argument allow to
# align the sequences with the blast algorithms.
#
# e.g bash src/bash/classify_set_reads_blast.sh \


# Function to check if the sequence folder exists.
function check_sequence_folder {
    #Check if -path_seq parameter is set.
    if [ -z ${PATH_SEQUENCES+x} ]
    then
        echo "-path_seq unset."
        echo "Error ! ."
        exit
    else
        if [ -d ${PATH_SEQUENCES} ]
        then
            echo $PATH_SEQUENCES
            echo "$PATH_SEQUENCES folder of sequence exist."
        else
            echo "Error $PATH_SEQUENCES doesn't exist."
            echo "No sequences for the blast algorithm."
            exit
        fi
    fi
}


# Function to check if blast database folder exists.
function check_blast_database_folder {
    #Check if -path_db parameter is set.
    if [ -z ${BLAST_DATABASE+x} ]
    then
        echo "-path_db unset."
        echo "Error ! No parameter blast database."
        exit
    else
        if [ -d ${BLAST_DATABASE} ]
        then
            echo $BLAST_DATABASE
            echo "$BLAST_DATABASE blast database folder exist."
        else
            echo "Error $BLAST_DATABASE doesn't exist."
            echo "We cannot do a blast analysis without a suitable database (see also create_blast_database.sh)."
            exit
        fi
    fi
}


function create_output_folder {
    # Create output folder of blast results.
    mkdir -p --verbose $OUTPUT_BLAST
}


function blast_all_sequences {
    for FASTA in PATH_SEQUENCES; do

        # For blast + (http://nebc.nerc.ac.uk/bioinformatics/documentation/blast+/user_manual.pdf)
        # blastn -task megablast : used to find very similar sequences.
        # -evalue : Expectation value threshold for saving hits.
        # -db : File name of BLAST database.
        # -outfmt : Allows for the specification of the search application’s output format.
        # -max_target_seqs : Maximum number of aligned sequences to keep from the blast database.
        # > output 
        blastn -task megablast \
               -evalue 10e-10 \
               -db $BLAST_DATABASE \
               -num_threads 1 \
               -outfmt \"7 qseqid sseqid sstart send evalue bitscore slen staxids\" \
               -max_target_seqs 1 \
               -max_hsps 1 \
               > $OUTPUT_BLAST${FASTA%%.*}_blast_temp.txt

        # Replace all "processed" to d.
        sed "/\processed\b/d" $OUTPUT_BLAST${%%.*}_blast_temp.txt \
            > $OUTPUT_BLAST${FASTA%%.*}_blast_temp2.txt

        # tac : concatenate and write files in reverse ?
        tac $OUTPUT_BLAST${FASTA%%.*}_blast_temp2.txt \
            | sed '/0 hits/I,+3 d' \
            | tac > $OUTPUT_BLAST${FASTA%%.*}_blast.txt
    done
}


function remove_intermediate_file {
    # Remove tempory files.
    rm -rf ${OUTPUT_BLAST}*_blast_temp.txt
    rm -rf ${OUTPUT_BLAST}*_blast_temp2.txt
}


PROGRAM=classify_set_reads_blast.sh
VERSION=1.0

DESCRIPTION=$(cat << __DESCRIPTION__

__DESCRIPTION__
           )

OPTIONS=$(cat << __OPTIONS__

## OPTIONS ##
    -path_seq    (Input)  Path to the folder that contains the sequences to be aligned.                 *DIR: results/classify_reads/trimmed_classify_fda_argos_with_none_library_02_07_2020/1-MAR-LBA-ADN_S1/convert_fastq_to_fasta/1-MAR-LBA-ADN.fasta
    -path_db     (Input)  Path to local blast database folder. (see create_blast_database.sh)           *DIR: data/refseq_genomics_virus_blast_db_17_07_2020/
    -path_output (Output) The folder of output blast classification.                                    *DIR: results/blast/refseq_result_blast_17_07_2020/
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
    echo "e.g : bash src/bash/classify_set_reads_blast.sh"
    echo -e $USAGE

    exit 1
}


# Check options
while [ -n "$1" ]; do
    case $1 in
        -h)                 USAGE      ; exit 0 ;;
        -path_seq)          PATH_SEQUENCES=$2 ; shift 2; continue ;;
        -path_db)           BLAST_DATABASE=$2 ; shift 2; continue ;;
        -path_output)       OUTPUT_BLAST=$2   ; shift 2; continue ;;
        *)       BAD_OPTION $1;;
    esac
done

# Check folder with sequences.
check_sequence_folder

# Check folder with blast database.
check_blast_database_folder

# Create output folder.
create_output_folder

# Blast the sequences.
blast_all_sequences

# Remove intermediate files.
remove_intermediate_file
