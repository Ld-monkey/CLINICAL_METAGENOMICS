#!/bin/bash

# Shell cluster script to launch preprocess on sequences or reads.
# This action removes poor quality and duplicates reads.
# old name => launch_preprocess.sh
# e.g remove_poor_quality_duplicate_reads.sh -path_reads all_reads_from_sample

PROGRAM=remove_poor_quality_duplicate_reads.sh
VERSION=1.0

DESCRIPTION=$(cat << __DESCRIPTION__

__DESCRIPTION__
           )

OPTIONS=$(cat << __OPTIONS__

## OPTIONS ##
    -path_reads      (Input)  The path of metagenomic reads folder.                                                *DIR: reads_sample
__OPTIONS__
       )

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
    echo "example : remove_poor_quality_duplicate_reads.sh -path_reads all_reads_from_sample"
    echo -e $USAGE

    exit 1
}

# Check options
while [ -n "$1" ]; do
    case $1 in
        -h)                    USAGE      ; exit 0 ;;
        -path_reads)           FOLDER_INPUT=$2    ; shift 2; continue ;;
        *)       BAD_OPTION $1;;
    esac
done

# Move to the folder of sequence.
cd ${FOLDER_INPUT}

# Check if the reads files from database are already decompressed.
reads_unzip=$(ls $DBNAME/taxonomy/*.gz 2> /dev/null | wc -l)
if [ "$reads_unzip" != "0" ]
then
    echo "Reads files are not unzipped."
    gunzip *.gz

    # List all R1*fasta.gz files same like ls *R1.fasta.gz.
    R1fastQgz=$(ls | grep -i R1.*\.fastq)
else
    echo "Reads files are already zipped."
    # list all R1*fasta.gz files same like ls *R1.fasta.gz
    R1fastQgz=$(ls | grep -i R1.*\.fastq\.gz)
fi

# list all R1*fasta.gz files same like ls *R1.fasta.gz
#R1fastQgz=$(ls | grep -i R1.*\.fastq\.gz)

# Important of zipped file in parameters ?

# Main loop
for R1fastQgzFile in ${R1fastQgz}; # For all R1 file in the folder.
do
    # Create a R2 file when the file is paired and replace R1 by R2.
    R2fastQgzFile=$(echo ${R1fastQgzFile} | sed 's/R1/R2/')

    # For R1 file they add R1_dedupe and R2_dedupe.
    dedupe1=$(echo ${R1fastQgzFile} | sed 's/R1/R1_dedupe/')
    dedupe2=$(echo ${R1fastQgzFile} | sed 's/R1/R2_dedupe/')

    # Paired reads.
    if [ -f "${R2fastQgzFile}" ];
    then
        # Count reads
        countReads=$(zcat ${R1fastQgzFile} | grep '^+$' | wc -l )

        # Multiply by 2 le number of R1 reads and create a info txt.
        echo $(($countReads * 2)) > ${R1fastQgzFile%%.*}.info.txt
        echo "PairedEnd Sample"

        # In BBTools : BMap is a splice-aware global aligner for DNA and RNA sequencing reads.
        clumpify.sh qin=33 in1=${R1fastQgzFile} in2=${R2fastQgzFile} out1=${dedupe1} out2=${dedupe2} dedupe

        echo "Deduplicated"
        # Using Trimmonatic a java program to deduplicate the replicat in paired reads.
        trimmomatic PE -threads 10 ${dedupe1} ${dedupe2} ${R1fastQgzFile%%.*}_paired.fq.gz ${R1fastQgzFile%%.*}_unpaired.fq.gz ${R2fastQgzFile%%.*}_paired.fq.gz ${R2fastQgzFile%%.*}_unpaired.fq.gz AVGQUAL:20 MINLEN:50

        # After we trimmed with removing of dedupe 1 and 2.
        echo "Trimmed"
        rm ${dedupe1} ${dedupe2}
    else
        # Count R1 read.
        zcat ${R1fastQgzFile} | grep '^+$' | wc -l > ${R1fastQgzFile%%.*}.info.txt

        echo "SingleEnd Sample"
        # In BBMAP??
        clumpify.sh qin=33 in=${R1fastQgzFile} out=${dedupe1} dedupe

        echo "Deduplicated"
        # Using deduplicate replicat into the reads.
        trimmomatic SE -threads 10 ${dedupe1} ${R1fastQgzFile%%.*}_trimmed.fq.gz AVGQUAL:20 MINLEN:50

        # After we trimmed with removing dedupe 1.
        echo "Trimmed"
        rm ${dedupe1}
    fi
done
