#!/bin/bash

# Shell cluster script to launch preprocess on sequences or reads.
# This action removes poor quality and duplicates reads.
# old name => launch_preprocess.sh
# e.g remove_poor_quality_duplicate_reads.sh \
#    -path_reads all_reads_from_sample/
#    -path_output results/trimmed_reads/

# Function to unzip sequences.
function unzip_sequences {
    
    # Check if the reads files from database are already decompressed.
    reads_unzip=$(ls $FOLDER_INPUT*.gz 2> /dev/null | wc -l)
    if [ "$reads_unzip" != "0" ]
    then
        echo "Reads files are not zipped."
        gunzip *.gz
        echo "Unzip done !"
    else
        echo "Reads files are already unzipped."
    fi
}


# Function to check if the output folder exists.
function check_output_folder {
    if [ -d $FOLDER_OUTPUT ]
    then
        echo "$FOLDER_OUTPUT folder already exits."
    else
        mkdir -v -p $FOLDER_OUTPUT
        echo "Create output folder $FOLDER_OUTPUT "
    fi
}


PROGRAM=remove_poor_quality_duplicate_reads.sh
VERSION=1.0

DESCRIPTION=$(cat << __DESCRIPTION__

__DESCRIPTION__
           )

OPTIONS=$(cat << __OPTIONS__

## OPTIONS ##
    -path_reads      (Input)  The path of metagenomic reads folder.                                                *DIR: reads_sample
    -path_output     (output) The folder of output reads trimmed.                                                  *DIR: output_reads_trimmed
__OPTIONS__
       )

# default options:
FOLDER_OUTPUT=$(pwd)

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
    echo "example : remove_poor_quality_duplicate_reads.sh -path_reads all_reads_from_sample/ -path_output output_reads_trimmed/"
    echo -e $USAGE

    exit 1
}

# Check options
while [ -n "$1" ]; do
    case $1 in
        -h)                    USAGE      ; exit 0 ;;
        -path_reads)           FOLDER_INPUT=$2    ; shift 2; continue ;;
        -path_output)          FOLDER_OUTPUT=$2   ; shift 2; continue ;;
        *)       BAD_OPTION $1;;
    esac
done

# Function to unzip reads.
unzip_sequences

# Check the output folder.
check_output_folder

# List all R1*fastq files.
ALL_R1_FASTQ_READS=$(ls $FOLDER_INPUT | grep -i R1.*\.fastq)

# Full path of reads.
for R1_READ in $ALL_R1_FASTQ_READS; do
    FULL_PATHS_ALL_R1_READS+="$FOLDER_INPUT$R1_READ "
done

# For all reads in the folder.
for R1_FASTQ_READ in $FULL_PATHS_ALL_R1_READS;
do
    # Create a R2 read name file to check if paired read exists.
    READ_FILE_R2=$(echo ${R1_FASTQ_READ} | sed 's/R1/R2/')

    # Create output dedupe name from all reads name for dedupe process.
    DEDUPE_R1=$(echo ${R1_FASTQ_READ} | sed 's/R1/R1_dedupe/')
    DEDUPE_R2=$(echo ${R1_FASTQ_READ} | sed 's/R1/R2_dedupe/')

    # Check if paired (R2) reads exists.
    if [ -f "${READ_FILE_R2}" ]
    then
        echo "Paired reads exists !"

        # Count reads
        countReads=$(zcat ${R1_FASTQ_READ} | grep '^+$' | wc -l )

        # Multiply by 2 le number of R1 reads and create a info txt.
        echo $(($countReads * 2)) > ${R1_FASTQ_READ%%.*}.info.txt

        echo "Run clumpify.sh to remove duplicate reads."
        # Clumpify which remove duplicate reads.
        clumpify.sh qin=33 \
                    in1=${R1_FASTQ_READ} \
                    in2=${READ_FILE_R2} \
                    out1=${DEDUPE_R1} \
                    out2=${DEDUPE_R2} \
                    dedupe
        echo -e "Clumpify.sh outputs are \n$DEDUPE_R1\n$DEDUPE_R2"
        echo "Remove duplicated reads done !"

        echo "Run trimmonatic to remove poor quality and small reads"
        # Using Trimmonatic a java program to remove poor quality of reads
        # not lower that 20 and too small reads not smaller that 50 nucleotides.
        # From Manual of Trimmomatic : https://datacarpentry.org/wrangling-genomics/03-trimming/
        # <inputFile1> 	Input reads to be trimmed.
        #     Typically the file name will contain an _1 or _R1 in the name.
        # <inputFile2> 	Input reads to be trimmed.
        #     Typically the file name will contain an _2 or _R2 in the name.
        # <outputFile1P> 	Output file that contains surviving pairs from the _1 file.
        # <outputFile1U> 	Output file that contains orphaned reads from the _1 file.
        # <outputFile2P> 	Output file that contains surviving pairs from the _2 file.
        # <outputFile2U> 	Output file that contains orphaned reads from the _2 file.
        trimmomatic PE -threads 10 \
                    ${DEDUPE_R1} \
                    ${DEDUPE_R2} \
                    ${R1_FASTQ_READ%%.*}_survivors_paired.fastq.gz \
                    ${R1_FASTQ_READ%%.*}_orphans_unpaired.fastq.gz \
                    ${READ_FILE_R2%%.*}_survivors_paired.fastq.gz \
                    ${READ_FILE_R2%%.*}_orphans_unpaired.fastq.gz \
                    AVGQUAL:20 \
                    MINLEN:50
        echo -e "Trimmonatic outputs are "
        echo "Trimomonatic done !"

        # After we trimmed with removing of paried dedupe.
        echo "Remove dedupe files : $DEDUPE_R1 and $DEDUPE_R2 to save space limit."
        rm $DEDUPE_R1 $DEDUPE_R2
    else
        echo "Not paired reads."

        # Count R1 read.
        zcat ${R1_FASTQ_READ} | grep '^+$' | wc -l > ${R1_FASTQ_READ%%.*}.info.txt

        echo "Run clumpify.sh to remove duplicate reads."
        # Clumpify which remove duplicate reads.
        clumpify.sh qin=33 \
                    in=${R1_FASTQ_READ} \
                    out=${DEDUPE_R1} \
                    dedupe
        echo -e "Clumpify.sh outputs are \n$DEDUPE_R1\n$DEDUPE_R2"
        echo "Remove duplicated reads done !"

        echo "Run trimmonatic to remove poor quality and small reads"
        # Using Trimmonatic to remove poor quality and too small reads.
        # From Manual of Trimmomatic : https://datacarpentry.org/wrangling-genomics/03-trimming/
        # <inputFile1> 	Input reads to be trimmed.
        #     Typically the file name will contain an _1 or _R1 in the name.
        # <outputFile1P> 	Output file that contains surviving pairs from the _1 file.
        trimmomatic SE -threads 10 \
                    ${DEDUPE_R1} \
                    ${R1_FASTQ_READ%%.*}_trimmed.fastq.gz \
                    AVGQUAL:20 \
                    MINLEN:50
        echo -e "Trimmonatic output is \n${R1_FASTQ_READ%%.*}_trimmed.fq.gz"

        # After we trimmed with removing of paried dedupe.
        echo "Remove dedupe $DEDUPE_R1 file to save space limit."
        rm ${DEDUPE_R1}
        echo "Remove done !"
    fi
done

# List all trimmed file in current directory.
ALL_TRIMMONATIC_OUTPUTS=$(ls $FOLDER_INPUT | grep -i "_survivors_paired\|_survivors_unpaired\|_orphans_paired\|_orphans_unpaired\|_trimmed")


# Full path of trimmed reads.
for TRIMMED_READ in $ALL_TRIMMONATIC_OUTPUTS; do
    FULL_PATH_TRIMMONATIC_OUTPUTS+="$FOLDER_INPUT$TRIMMED_READ "
done

# Move trimmed file.
echo "Move all trimmed files in $FOLDER_OUTPUT."
for TRIMMONATIC_OUTPUT in $FULL_PATH_TRIMMONATIC_OUTPUTS;
do
    mv -v $TRIMMONATIC_OUTPUT $FOLDER_OUTPUT
done
echo "Move done !"
