#!/bin/bash

# From a set of reads and depend of the database gived in argument
# allow to classify the reads sequences.
# problem : paired sequence must named *R1*.fastq (* = something before and after).
# output files : *.clseqs_*.fastq, *.unclseq_*.fq, *.output.txt, *.report.txt .
# *.clseqs.fastq : all classified reads
# *.unclseqs.fastq : all unclassified reads
# *.output.txt : ??
# *.report.txt : all claffication of organism classified.
# e.g ./classify_set_sequences.sh -path_reads all_reads_from_sample \
#    -path_db database_FDA_ARGOS -path_output output_result -threads 1

PROGRAM=classify_set_sequences.sh
VERSION=1.0

DESCRIPTION=$(cat << __DESCRIPTION__

__DESCRIPTION__
           )

OPTIONS=$(cat << __OPTIONS__

## OPTIONS ##
    -path_reads      (Input)  The path of metagenomic read.                                                *FILE: sequences.fastq
    -path_db         (Input)  The path of database containt hash.k2d + opts.k2d + taxo.k2d .               *DIR: input_database
    -path_output     (output) The folder of output kraken 2 download_taxonomy_database.sh                  *DIR: output_database
    -threads         (Input)  The number of threads to classify faster.                                    *INT: 1
__OPTIONS__
       )

# default options if they are not defined:
path_output=output_result_from_kraken2
threads=1

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
    echo "example : ./classify_set_sequences.sh -path_reads all_reads_from_sample -path_db database_FDA_ARGOS -path_output output_result -threads 1"
    echo -e $USAGE

    exit 1
}

# Check options
while [ -n "$1" ]; do
    case $1 in
        -h)                    USAGE      ; exit 0 ;;
        -path_reads)           PATH_ALL_READS=$2    ; shift 2; continue ;;
  	    -path_db)              DBNAME=$2            ; shift 2; continue ;;
        -path_output)          FOLDER_OUTPUT=$2     ; shift 2; continue ;;
    	  -threads)              THREAD=$2            ; shift 2; continue ;;
        *)       BAD_OPTION $1;;
    esac
done

# Check if all sequences are unziped.
sequences_unzip=$(ls $PATH_ALL_READS/*.gz 2> /dev/null | wc -l)
if [ "$sequences_unzip" != 0 ]
then
    echo "Unzip all sequences files"
    gunzip $PATH_ALL_READS/*.gz
    echo "$PATH_ALL_READS Unzip done !"
else
    echo "$PATH_ALL_READS files are already decompressed"
fi

# Check if the folder for output kraken 2 results exists.
if [ -d $FOLDER_OUTPUT ]
then
    echo "$FOLDER_OUTPUT folder already exits."
else
    mkdir $FOLDER_OUTPUT
    echo "Create folder $FOLDER_OUTPUT "
fi

# After created database we can classify a set of sequences with kraken2.
# change with --paired + --output parameters
echo "Run classify a set of sequences with kraken 2"
for all_sequences in $PATH_ALL_READS/*R1*.fastq
do
    prefix=$(basename "$all_sequences" | awk -F "R1" '{print $1}')
    suffix=$(basename "$all_sequences" | awk -F "R1" '{print $2}')
    paired_file="$prefix""R2""$suffix"
    echo "In the sequence : $all_sequences"
    echo "The prefix name file is : $prefix"
    echo "The suffix name file is : $suffix"
    echo "So the name of his paired file is : $paired_file"
    kraken2 --db $DBNAME --threads $THREAD --paired --report $FOLDER_OUTPUT/$prefix.report.txt --classified-out $FOLDER_OUTPUT/$prefix.clseqs#.fastq --unclassified-out $FOLDER_OUTPUT/$prefix.unclseq#.fq --output $FOLDER_OUTPUT/$prefix.output.txt $all_sequences $PATH_ALL_READS/$paired_file
done
