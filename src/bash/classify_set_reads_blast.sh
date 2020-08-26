#!/bin/bash

# From a set of reads and depend of the database gived in argument allow to
# align the sequences with the blast algorithms.
# Warning : For moment doesn't take  into account compressed fasta files like
# fasta.gz .
# e.g bash src/bash/classify_set_reads_blast.sh \
#          -path_seq results/classify_reads/trimmed_classify_fda_argos_with_none_library_02_07_2020/1-MAR-LBA-ADN_S1/convert_fastq_to_fasta/ \
#          -path_db data/refseq_genomics_virus_blast_db_17_07_2020/ \    
#          -path_output results/blast/refseq_result_blast_17_07_2020/ \
#          -threads 10


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
            echo "`basename $PATH_SEQUENCES` folder of sequence exist."
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
            echo "`basename $BLAST_DATABASE` blast database folder exist."
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

    COMPLETE_OUTPUT=$OUTPUT_BLAST${BASENAME_WITHOUT_EXTENSION}_blast_temp.out

    # For blastn documentation see also :
    # http://nebc.nerc.ac.uk/bioinformatics/documentation/blast+/user_manual.pdf
    # -db : File name of BLAST database.
    # -query : the sequence to compare.
    # -task : megablast used to find very similar sequences.
    # -out : output file.
    # -evalue : Expectation value threshold for saving hits.
    # -outfmt : Allows for the specification of the search application’s output format.
    # -max_hsps : Maximum number of HSPs (alignments) to keep for any single query-subject pair.
    # -max_target_seqs : Maximum number of aligned sequences to keep from the blast database.
    # -num_threads : Number of threads.
    
    blastn -db $BLAST_DATABASE$NAME_DATABASE \
           -query $FASTA \
           -task "megablast" \
           -out $COMPLETE_OUTPUT \
           -evalue 10e-10 \
           -outfmt "7 qseqid sseqid sstart send evalue bitscore slen staxids" \
           -max_hsps 1 \
           -max_target_seqs 5 \
           -num_threads $THREADS

    echo "Blast done !"

    echo "Delete last line of file."
    # Delete last line of file.
    sed "/\processed\b/d" $OUTPUT_BLAST${BASENAME_WITHOUT_EXTENSION}_blast_temp.out \
      > $OUTPUT_BLAST${BASENAME_WITHOUT_EXTENSION}_blast_temp_2.out
    echo "Delete done !"

    # The goal is to remove 0 hits from the blast output. As the 0 hits are usually
    # towards the end of the file we read the file upside down with 'tac' command
    # then we put it right side up on other output.
    echo "Remove 0 hits from blast output."
    tac $OUTPUT_BLAST${BASENAME_WITHOUT_EXTENSION}_blast_temp_2.out \
        | sed '/0 hits/I,+3 d' \
        | tac > $OUTPUT_BLAST${BASENAME_WITHOUT_EXTENSION}_blast.txt
    echo "Remove 0 hits done !"
}


function remove_intermediate_file {
    # Remove tempory files.
    rm -rf $OUTPUT_BLAST${BASENAME_WITHOUT_EXTENSION}_blast_temp.out
    rm -rf $OUTPUT_BLAST${BASENAME_WITHOUT_EXTENSION}_blast_temp_2.out
    echo "Remove done !"
}

PROGRAM=classify_set_reads_blast.sh
VERSION=1.0

DESCRIPTION=$(cat << __DESCRIPTION__

__DESCRIPTION__
           )

OPTIONS=$(cat << __OPTIONS__

## OPTIONS ##
    -path_seq    (Input)    Path to the folder that contains the sequences to be aligned.                 *DIR: results/classify_reads/trimmed_classify_fda_argos_with_none_library_02_07_2020/1-MAR-LBA-ADN_S1/convert_fastq_to_fasta/
    -path_db     (Input)    Path to local blast database folder. (see create_blast_database.sh)           *DIR: data/refseq_genomics_virus_blast_db_17_07_2020/
    -path_output (Output)   The folder of output blast classification.                                    *DIR: results/blast/refseq_result_blast_17_07_2020/
    -threads     (Optional) The number of threads to classify faster.                                     *INT: 10
__OPTIONS__
       )

# default options:
THREADS=10

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
        -threads)           THREADS=$2        ; shift 2; continue ;;
        *)       BAD_OPTION $1;;
    esac
done

echo "Number of threads : $THREADS"

# Check folder with sequences.
check_sequence_folder

# Check folder with blast database.
check_blast_database_folder

# Create output folder.
create_output_folder

# Get the name of blast database.
NAME_DATABASE=$(ls ${BLAST_DATABASE}*.n* | head -n 1)
NAME_DATABASE=$(basename ${NAME_DATABASE%%.*})

# Blast the sequences.
for FASTA in ${PATH_SEQUENCES}*.fasta; do
    echo "fasta = $FASTA"
    BASENAME_WITHOUT_EXTENSION=$(basename ${FASTA%%.*} )
    echo "basename = $BASENAME_WITHOUT_EXTENSION"
    blast_all_sequences
done

# Remove intermediate files.
remove_intermediate_file
