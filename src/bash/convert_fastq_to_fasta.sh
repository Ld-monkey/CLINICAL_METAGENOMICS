#!/bin/bash

# Because some tools like blast alignment need a file in fasta format. It is
# important in some cases to transform the fastq file into a fasta or fna file.
#
# e.g bash src/bash/convert_fastq_to_fasta \
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
    echo "e.g "
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

# Check for no paired sequences (only fastq1 is necessary).
if [[ -s $READS_LIST && -s $CLASSIFIED_SEQUENCE_FASTQ1 ]]
then
    
    # The temporary file for seqtk.
    TEMPORARY_FILE=$(dirname $READS_LIST)_temporary.fq
    echo " temporary file : $TEMPORARY_FILE"   

    echo "First condition"
    echo "read list $READS_LIST exists."
    echo "classified sequences $CLASSIFIED_SEQUENCE_FASTQ1 exists".

    # Extract sequences with names in file name.lst (READS_LIST) one sequence name per line.
    seqtk subseq $CLASSIFIED_SEQUENCE_FASTQ1 $READS_LIST > ${TEMPORARY_FILE}

    # Convert fastq to fasta (.fa).
    seqtk seq -a $TEMPORARY_FILE > $OUTPUT_INTEREST_FASTA

    # Check if seqtk return (0) for a success and $? return previous command seqtk seq -a. 
    if [ $? -eq 0 ]
    then
        # Remove tempory file.
        #rm $TEMPORARY_FILE

        echo "Reads recovered for $CLASSIFIED_SEQUENCE_FASTQ1."
        echo "The output is $OUTPUT_INTEREST_FASTA in .fasta format."
    else
        echo "Reads not recovered for $CLASSIFIED_SEQUENCE_FASTQ1"
        echo "FAIL for $CLASSIFIED_SEQUENCE_FASTQ1"
    fi

else
    echo "$CLASSIFIED_SEQUENCE_FASTQ1 or/and $READS_LIST are empty"
fi

# Check if ReadList.txt + *clseqs_1 + *clseqs_2 exists and has a size greater than zero.
if [[ -s $READS_LIST && -s $CLASSIFIED_SEQUENCE_FASTQ1 && -s $CLASSIFIED_SEQUENCE_FASTQ2 ]]
then
    # The temporary file for seqtk.
    TEMPORARY_FILE=$(dirname $READS_LIST)_temporary.fq
    echo " temporary file : $TEMPORARY_FILE"   

    echo "2nd condition"
    echo "The $READS_LIST exists"
    echo "The $CLASSIFIED_SEQUENCE_FASTQ1 exists"
    echo "The $CLASSIFIED_SEQUENCE_FASTQ2 exists"

    # Seqtk is a fast and lightweight tool for processing sequences in
    # the FASTA or FASTQ format. It seamlessly parses both FASTA and FASTQ files.
    # Extract sequences with names in file name.lst (READS_LIST) one sequence name per line.
    seqtk subseq $CLASSIFIED_SEQUENCE_FASTQ1 $READS_LIST > ${TEMPORARY_FILE}

    # Convert fastq to fasta.
    seqtk seq -a $TEMPORARY_FILE > $OUTPUT_INTEREST_FASTA

    # Check if seqtk return (0) for a success and $? return previous command seqtk seq -a. 
    if [ $? -eq 0 ]
    then
        # Remove tempory file.
        #rm $TEMPORARY_FILE

        echo "Reads recovered for $CLASSIFIED_SEQUENCE_FASTQ1."
        echo "The output is $OUTPUT_INTEREST_FASTA in .fasta format."
    else
        echo "Reads not recovered for $CLASSIFIED_SEQUENCE_FASTQ1"
        echo "FAIL for $CLASSIFIED_SEQUENCE_FASTQ1"
    fi

    # The temporary file for seqtk.
    TEMPORARY_FILE_2=$(dirname $READS_LIST)_temporary_2.fq
    echo " temporary file : $TEMPORARY_FILE"   

    # Toolkit to transform fastq2 to fasta with tempory file.
    seqtk subseq $CLASSIFIED_SEQUENCE_FASTQ1 $READS_LIST > $TEMPORARY_FILE_2
    seqtk seq -a $TEMPORARY_FILE_2 >> $OUTPUT_INTEREST_FASTA

    # Check if seqtk return (0) for a success and $? return previous command seqtk seq -a. 
    if [ $? -eq 0 ]
    then
        # Remove tempory file.
        #rm $TEMPORARY_FILE_2

        echo "Reads recovered for $CLASSIFIED_SEQUENCE_FASTQ2."
        echo "The output is concatenate in $OUTPUT_INTEREST_FASTA in .fasta format."
    else
        echo "Reads not recovered for $CLASSIFIED_SEQUENCE_FASTQ2"
        echo "FAIL for $CLASSIFIED_SEQUENCE_FASTQ1"
    fi
fi
