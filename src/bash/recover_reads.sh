#!/bin/bash

# Gets reads in "clseqs" files from names,
# and transforms them into fasta format.
# e.g ./recover_reads \
#      -reads_list ReadsList.txt
#      -clseqs_1 clseqs_1.fastq
#      -clseqs_2 clseqs_2.fastq
#      -output output_interest_fasta.fasta

PROGRAM=recover_reads.sh
VERSION=1.0

DESCRIPTION=$(cat << __DESCRIPTION__

__DESCRIPTION__
           )

OPTIONS=$(cat << __OPTIONS__

## OPTIONS ##
    -reads_list   (Input) The ReadsList.txt file containt all parameters to find sequences of interest.    *FILE: ReadsList.txt
    -clseqs_1     (Input) The classified sequences in first paired sequences named *clseqs_1.fastq .       *FILE: *clseqs_1.fastq
    -clseqs_2     (Input) The classified sequences in second paired sequences named *clseqs_2.fastq .      *FILE: *clseqs_2.fastq
    -output       (Output) The output name of the sequence of interest named *.interesting.fasta .         *STRING: result_example
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
    echo "example :./recover_reads -reads_list ReadsList.txt -clseqs_1 clseqs_1.fastq -clseqs_2 clseqs_2.fastq -output output_interest_fasta.fasta"
    echo -e $USAGE

    exit 1
}

# Check options
while [ -n "$1" ]; do
    case $1 in
        -h)                    USAGE      ; exit 0 ;;
        -reads_list)           READS_LIST=$2                    ; shift 2; continue ;;
  	    -clseqs_1)             CLASSIFIED_SEQUENCE_FASTQ1=$2    ; shift 2; continue ;;
    	  -clseqs_2)             CLASSIFIED_SEQUENCE_FASTQ2=$2    ; shift 2; continue ;;
        -output)               OUTPUT_INTEREST_FASTA=$2         ; shift 2; continue ;;
        *)       BAD_OPTION $1;;
    esac
done

# Create folder that containing temporary file.
TEMPORARY_DIR=../../results/temporary_file/

# Check if temporary folder exists. (Ca ne sert a rien.)
# Mieux vaut créer les fichiers dans des dossiers spécifiques puis supprimer.
if [ -d $TEMPORARY_DIR ]
then
    echo " Path : $TEMPORARY_DIR"
else
    mkdir --verbose $TEMPORARY_DIR
fi

# Check for no paired sequences (only fastq1 is necessary).
if [[ -s $READS_LIST && -s $CLASSIFIED_SEQUENCE_FASTQ1 ]]
then

    echo "The $READS_LIST exists"
    echo "The $CLASSIFIED_SEQUENCE_FASTQ1 exists"

    # Seqtk is a fast and lightweight tool for processing sequences in
    # the FASTA or FASTQ format. It seamlessly parses both FASTA and FASTQ files.

    # Extract sequences with names in file name.lst (READS_LIST)
    # one sequence name per line.
    seqtk subseq $CLASSIFIED_SEQUENCE_FASTQ1 $READS_LIST > ${temp_file}.fq

    # basename classified ==> 1-MAR-LBA-ADN_S1.temporary.fq

    # Convert fastq to fasta (???)
    seqtk seq -a ${temp_file}.fq > $OUTPUT_INTEREST_FASTA

    # basename classified ==> 1-MAR-LBA-ADN_S1.final.fq

    # Check if Toolkit return code for a successful retunr (0).
    # $? return previous command seqtk seq -a. 
    if [ $? -eq 0 ]
    then
        # Remove tempory file.
        rm ${temp_file}.fq

        echo "Reads recovered for $CLASSIFIED_SEQUENCE_FASTQ1"
        echo "The output is $OUTPUT_INTEREST_FASTA in .fa format"
    else
        echo "Reads not recovered for $CLASSIFIED_SEQUENCE_FASTQ1"
        echo "FAIL for $CLASSIFIED_SEQUENCE_FASTQ1"
    fi

else
    echo "$CLASSIFIED_SEQUENCE_FASTQ1 or/and $READS_LIST are empty"
fi

# -s : Check if ReadList.txt + *clseqs_1 + *clseqs_2 exists and has a size
# greater than zero.
if [[ -s $READS_LIST && -s $CLASSIFIED_SEQUENCE_FASTQ1 && -s $CLASSIFIED_SEQUENCE_FASTQ2 ]]
then

    echo "The $READS_LIST exists"
    echo "The $CLASSIFIED_SEQUENCE_FASTQ1 exists"
    echo "The $CLASSIFIED_SEQUENCE_FASTQ2 exists"
    
    # Tempory files in bash. (ca ne sert a rien !)
    temp_file=$(mktemp)
    temp_fasta=$(mktemp)

    # Seqtk is a fast and lightweight tool for processing sequences in
    # the FASTA or FASTQ format. It seamlessly parses both FASTA and FASTQ files.

    # Extract sequences with names in file name.lst (READS_LIST)
    # one sequence name per line.
    seqtk subseq $CLASSIFIED_SEQUENCE_FASTQ1 $READS_LIST > ${temp_file}.fq

    # Convert fastq to fasta (???)
    seqtk seq -a ${temp_file}.fq > ${temp_fasta}.fa

    # Toolkit return code for a successful completion (0).
    # $? return previous command seqtk seq -a.
    if [ $? -eq 0 ]; then

        # Remove the tempory files.
        rm $temp_file

        # Check if tempory fasta exists.
        if [[ -s $temp_fasta ]]
        then
            echo "Reads recovered for $CLASSIFIED_SEQUENCE_FASTQ1"
        else
            echo "Reads not recovered for $CLASSIFIED_SEQUENCE_FASTQ1"
        fi
    else
        echo "FAIL for $CLASSIFIED_SEQUENCE_FASTQ1"
    fi

    # A other tempory files in bash.
    temp_file1=$(mktemp)
    temp_fasta1=$(mktemp)

    # Toolkit to transform fastq2 to fasta with tempory file.
    seqtk subseq  $CLASSIFIED_SEQUENCE_FASTQ2 $READS_LIST >  $temp_file1
    seqtk seq -a $temp_file1 > $temp_fasta1

    # Same condition that before (can be a function) but for fastq2.
    if [ $? -eq 0 ]; then

        # Remove the tempory file.
        rm $temp_file1

        # Check if tempory fasta exists.
        if [[ -s $temp_fasta1 ]]
        then
            echo "Reads recovered for $CLASSIFIED_SEQUENCE_FASTQ2"
        else
            echo "Reads not recovered for $CLASSIFIED_SEQUENCE_FASTQ2"
        fi
    else
        echo "FAIL for $CLASSIFIED_SEQUENCE_FASTQ2"
    fi

    # Check if fastq1 and fastq2 exists.
    if [[ -s $temp_fasta && -s $temp_fasta1 ]]
    then
        # Then concatenate fastq1 and fastq2 in output *.interesting.fasta .
        cat $temp_fasta $temp_fasta1  >  ${OUTPUT_INTEREST_FASTA}

        # And clean the tempory files after concatenate.
        rm $temp_fasta
        rm $temp_fasta1

        # Check if only fastq2 exists.
    elif [[ ! -s $temp_fasta && -s $temp_fasta1 ]]
    then
        # rename the fastq2 to *.interesting.fasta .
        mv $temp_fasta1 ${OUTPUT_INTEREST_FASTA}
        
        # Check if only fastq1 exists.
    elif [[ -s $temp_fasta && ! -s $temp_fasta1 ]]
    then
        # Rename the fastq1 to *.interestring.fasta.
        mv $temp_fasta ${OUTPUT_INTEREST_FASTA}
    elif [[ ! -s $temp_fasta && ! -s $temp_fasta1 ]]
    then
        echo "Non reads recovered at all"
    fi
fi
