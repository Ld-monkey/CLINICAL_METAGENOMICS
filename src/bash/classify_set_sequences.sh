#!/bin/bash

# From a set of reads and depend of the database gived in argument
# allow to classify the reads sequences.
# Note : paired sequence must named *R1*.fastq (* = something before and after).
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

# List all survivors reads files.
ALL_SURVIVORS_READS=$(ls $PATH_ALL_READS*R1* | grep -i "_survivors_paired\|_trimmed")

# Classify a set of sequences or reads with kraken2 tool.
echo "Run classify a set of sequences with kraken 2"
for R1_READ in $ALL_SURVIVORS_READS
do

    # Get prefix name for outputs.
    prefix=$(basename "$R1_READ" | awk -F "_R1" '{print $1}')

    # Create a R2 read name file to check if paired read exists.
    R2_PAIRED_READ=$(echo ${R1_READ} | sed 's/R1/R2/')

    echo "all survivors : $ALL_SURVIVORS_READS"
    echo "R1 reads : $R1_READ"
    echo "R2 reads : $R2_PAIRED_READ"
    echo "db : $DBNAME"
    echo "threads : $THREAD"
    echo "report : $FOLDER_OUTPUT${prefix}_taxon.report.txt"
    echo "--classified-out $FOLDER_OUTPUT$prefix.clseqs#.fastq"
    echo "--unclassified-out $FOLDER_OUTPUT$prefix.unclseq#.fastq"
    echo "--output $FOLDER_OUTPUT$prefix.output.txt"
    echo "R1 input $R1_READ "
    echo "R2 input $R2_PAIRED_READ"

    # Check if paired (R2) reads exists.
    if [ -f "${R2_PAIRED_READ}" ]
    then
        echo "Paired reads exists !"

        echo "Run kraken 2 classification reads."
        # --db : specific kraken 2 database.
        # --threads : NUM switch to use multiple threads.
        # --paired : Indicate to kraken2 that the input files provided are paired read data.
        # --report : format is tab-delimited with one line per taxon.
        # (see https://ccb.jhu.edu/software/kraken2/index.shtml?t=manual#sample-report-output-format)
        # --classified-out, --unclassified-out : classified or unclassified sequences.
        # --output : output direction ?? .
        # input R1_paired_read file.
        # input R2_paired_read file.
        kraken2 --db $DBNAME \
                --threads $THREAD \
                --paired \
                --report $FOLDER_OUTPUT/${prefix}_taxon.report.txt \
                --classified-out $FOLDER_OUTPUT/$prefix.clseqs#.fastq \
                --unclassified-out $FOLDER_OUTPUT/$prefix.unclseq#.fastq \
                --output $FOLDER_OUTPUT/$prefix.output.txt \
                $R1_READ $R2_PAIRED_READ
        echo "Kraken 2 classification done !"
    else
        echo "Not paired reads."

        echo "Run kraken 2 classification reads."
        Run kraken 2 classification on no paired read.
        kraken2 --db $DBNAME \
                --threads $THREAD \
                --report $FOLDER_OUTPUT/${prefix}_taxon.report.txt \
                --classified-out $FOLDER_OUTPUT/$prefix.clseqs#.fastq \
                --unclassified-out $FOLDER_OUTPUT/$prefix.unclseq#.fastq \
                --output $FOLDER_OUTPUT/$prefix.output.txt \
                $R1_READ
        echo "Kraken 2 classification done !"
    fi
done
