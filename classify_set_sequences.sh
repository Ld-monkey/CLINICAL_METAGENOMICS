#!/bin/bash

# First argument take the path of metagenomic read.
PATH_ALL_READS=$1

# Seconde argument take the path of database containt hash.k2d + opts.k2d + taxo.k2d .
DBNAME=$2

# Thirds augment is the number of cpu
THREAD=$3

# 4th argument the folder of output kraken 2 taxonomy
FOLDER_OUTPUT=$4

# Check if all sequences are unziped.
# /data1/scratch/masalm/Valid_Mg_Groute/190710-Nextseq-bact/FASTQ
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
for all_sequences in $PATH_ALL_READS/*R1.fastq
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
