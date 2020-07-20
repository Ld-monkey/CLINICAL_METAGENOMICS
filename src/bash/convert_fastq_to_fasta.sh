#!/bin/bash

# Because some tools like blast alignment need a file in fasta format. It is
# important in some cases to transform the fastq file into a fasta or fna file.
# One of the advantages of using seqtk in this script is that it can take into
# account specific lists to select the sequences you want to take.
# To have more details on seqtk see also https://github.com/lh3/seqtk .
#
# e.g bash src/bash/convert_fastq_to_fasta \
#                 -path_fastq_1 results/trimmed_classify/1-MAR-LBA-ADN_S1_clseqs_1.fastq \
#                 -path_fastq_2 results/trimmed_classify/1-MAR-LBA-ADN_S1_clseqs_2.fastq \
#                 -path_list    results/list_taxon/bacteria.lst \
#                 -output_fasta results/convertion_fastq_2_fasta/bacteria_1-MAR-LBA-ADN_S1.fasta


function create_output_folder {
    # Create output folder of output_fasta file.
    mkdir -p --verbose "$(dirname "$OUTPUT_FASTA")"
    OUTPUT_FOLDER="$(dirname "$OUTPUT_FASTA")"/
}


function check_paired_sequences {
    # Check if the sequences are in pairs.
    if [[ -f "$FASTQ1" ]] && ([[ -n "${FASTQ2+x}" ]] && [[ -f "$FASTQ2" ]]); then
        echo "Paired sequences"
        FLAG_PAIRED_SEQUENCE="yes"
        echo `basename $FASTQ1`
        echo `basename $FASTQ2`
    else
        echo "Not paired sequences"
        echo `basename $FASTQ1`
        FLAG_PAIRED_SEQUENCE="no"
    fi
}


function check_list_parameter {
    # Checks if a list is specified as a parameter.
    if [ -z ${LIST+x} ]; then
        echo "-path_list unset."
        echo "Warning ! No list was selectionned !"
        FLAG_LIST_BOOLEAN="False"
    else
        echo  "-path_list set."
        if [ -f "$LIST" ]; then
            echo "`basename $LIST` list file exists."
            FLAG_LIST_BOOLEAN="True"
        else
            echo "Error parameter -path_list was indicate but $LIST list file doesn't exists."
            exit
        fi
    fi
}


function check_correct_execution_seqtk {
    # Check if seqtk return (0) for a success and $? return previous command
    # seqtk seq -a. 
    if [ $? -eq 0 ]
    then
        echo "Conversion has been completed."
        echo "The output is $OUTPUT_FASTA in .fasta format."
    else
        echo "Conversion hasn't been completed !"
        echo "FAIL !"
        exit
    fi
}


function convert_fastq_to_fasta {
    echo $FLAG_PAIRED_SEQUENCE
    echo $FLAG_LIST_BOOLEAN

    # Convert fastq files to fasta file.
    if [[ $FLAG_PAIRED_SEQUENCE = "yes" ]]; then
        if [[ $FLAG_LIST_BOOLEAN = "True" ]]; then
            # Paired + list.
            echo "Paired + list."

            # The temporary file for seqtk.
            TEMPORARY_FILE_2="temporary_2.fq"
            echo " temporary file : $TEMPORARY_FILE"

            # Extract sequences with names in file name.lst (LIST) one sequence
            # name per line.
            seqtk subseq $FASTQ1 $LIST > $OUTPUT_FOLDER$TEMPORARY_FILE

            # Convert fastq to fasta.
            seqtk seq -a $OUTPUT_FOLDER$TEMPORARY_FILE > $OUTPUT_FASTA

            # Check good execution of seqtk program.
            check_correct_execution_seqtk

            # Toolkit to transform fastq to fasta with tempory file.
            seqtk subseq $FASTQ2 $LIST > $OUTPUT_FOLDER$TEMPORARY_FILE_2

            # Convert fastq to fasta and concatenate.
            seqtk seq -a $OUTPUT_FOLDER$TEMPORARY_FILE_2 >> $OUTPUT_FASTA

            # Check good execution of seqtk program.
            check_correct_execution_seqtk
        else
            # Paired but not list.
            echo "Paired but not list."

            # Convert fastq to fasta for paired sequences and concatenate.
            seqtk seq -a $FASTQ1 > $OUTPUT_FASTA
            seqtk seq -a $FASTQ2 >> $OUTPUT_FASTA

            # Check good execution of seqtk program.
            check_correct_execution_seqtk
        fi
    else
        if [[ $FLAG_LIST_BOOLEAN = "True" ]]; then
            # No paired + list.
            echo "No paired + list."

            # Extract sequences with names in file name.lst (LIST) one sequence
            # name per line.
            seqtk subseq $FASTQ1 $LIST > $OUTPUT_FOLDER${TEMPORARY_FILE}

            # Convert fastq to fasta (.fa).
            seqtk seq -a $OUTPUT_FOLDER$TEMPORARY_FILE > $OUTPUT_FASTA

            # Check good execution of seqtk program.
            check_correct_execution_seqtk
        else
            # Not paired and not list.
            echo "Not paired and not list."

            # Convert fastq to fasta for paired sequences.
            seqtk seq -a $FASTQ1 > $OUTPUT_FASTA

            # Check good execution of seqtk program.
            check_correct_execution_seqtk
        fi
    fi
}


function remove_intermediate_file {
    # Remove tempory file.
    rm -rf --verbose $OUTPUT_FOLDER$TEMPORARY_FILE
    rm -rf --verbose $OUTPUT_FOLDER$TEMPORARY_FILE_2
}

PROGRAM=convert_fastq_to_fasta.sh
VERSION=1.0

DESCRIPTION=$(cat << __DESCRIPTION__

__DESCRIPTION__
           )

OPTIONS=$(cat << __OPTIONS__

## OPTIONS ##
    -path_fastq_1 (Input)     Sequences in fastq format to convert in fasta format.                                  *FILE: results/trimmed_classify/1-MAR-LBA-ADN_S1_clseqs_1.fastq
    -path_fastq_2 (Optional)  The classified sequences in second paired sequences named *clseqs_2.fastq .            *FILE: results/trimmed_classify/1-MAR-LBA-ADN_S1_clseqs_2.fastq
    -path_list    (Optional)  Select a list of specific sequences see also python/get_list_of_classified_organism.py *FILE: results/list_taxon/bacteria.lst
    -output_fasta (Output)    The name of the output sequence in fasta format                                        *STR : results/convertion_fastq_2_fasta/bacteria_1-MAR-LBA-ADN_S1.fasta
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
    echo "e.g "
    echo -e $USAGE

    exit 1
}

# Check options
while [ -n "$1" ]; do
    case $1 in
        -h)                    USAGE      ; exit 0 ;;
        -path_fastq_1)         FASTQ1=$2       ; shift 2; continue ;;
        -path_fastq_2)         FASTQ2=$2       ; shift 2; continue ;;
        -path_list)            LIST=$2         ; shift 2; continue ;;
        -output_fasta)         OUTPUT_FASTA=$2 ; shift 2; continue ;;
        *)       BAD_OPTION $1;;
    esac
done

# Create output folder if doesn't exists.
create_output_folder

# Check if paired or not sequences.
check_paired_sequences

# Check if reads list is precised if not display a message.
check_list_parameter

# The temporary file for seqtk.
TEMPORARY_FILE="temporary_1.fq"
echo "Temporary file : $TEMPORARY_FILE"   

# Transfort fastq sequences to fasta (can extract sequences with a list).
convert_fastq_to_fasta

# Remove intermediate files.
remove_intermediate_file
