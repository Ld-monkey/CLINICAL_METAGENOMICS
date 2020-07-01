#!/bin/bash

# Shell cluster script to launch pre-process on reads.
# This action removes poor quality, duplicates and small reads.
# Old name => launch_preprocess.sh
# e.g bash src/bash/remove_poor_quality_duplicate_reads_preprocess.sh \
#     -path_reads data/reads/PAIRED_SAMPLES_ADN_TEST/ \
#     -path_output results/trimmed_reads/trimmed_PAIRED_SAMPLES_ADN_TEST_reads_04_06_2020/
#     -threads 28

# Function to check if the read folder exists.
function check_read_folder {

    # Check if parameter is set. 
    if [ -z ${FOLDER_INPUT+x} ]
    then
        echo "-path_reads is unset."
        echo "exit"
        exit
    else
        if [ -d ${FOLDER_INPUT} ]
        then
            echo $FOLDER_INPUT
            echo "$FOLDER_INPUT folder of read exist."
        else
            echo "Error $FOLDER_INPUT doesn't exist."
            exit
        fi
    fi
}


# Function to check if the output folder is set.
function check_output_folder {

    # Check if parameter is set.
    if [ -z ${FOLDER_OUTPUT+x} ]
    then
        echo "-path_output is unset"
        echo "You must specify the -path_output parameter"
        echo "exit"
        exit
    else
        echo "-path_output is set"

        # Check the output folder.
        check_output_folder
    fi

}

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


PROGRAM=remove_poor_quality_duplicate_reads_preprocess.sh
VERSION=1.0

DESCRIPTION=$(cat << __DESCRIPTION__

__DESCRIPTION__
           )

OPTIONS=$(cat << __OPTIONS__

## OPTIONS ##
    -path_reads      (Input)  The path of metagenomic reads folder.                                                *DIR: reads_sample
    -path_output     (output) The folder of output reads trimmed.                                                  *DIR: output_reads_trimmed
    -threads         (Input)  The number of thread.                                                                *INT: 6
    -force_remove    (Optional) By default the value is yes and allows you to delete intermediate files.           *STR: yes|no
__OPTIONS__
       )

# default options:
THREAD=1
FORCE_REMOVE=yes

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
    echo "example : bash src/bash/remove_poor_quality_duplicate_reads_preprocess.sh -path_reads data/reads/PAIRED_SAMPLES_ADN_TEST/ -path_output results/trimmed_reads/trimmed_PAIRED_SAMPLES_ADN_TEST_reads_04_06_2020/ -threads 28"

    echo -e $USAGE

    exit 1
}

# Check options
while [ -n "$1" ]; do
    case $1 in
        -h)                    USAGE      ; exit 0 ;;
        -path_reads)           FOLDER_INPUT=$2    ; shift 2; continue ;;
        -path_output)          FOLDER_OUTPUT=$2   ; shift 2; continue ;;
        -threads)              THREAD=$2          ; shift 2; continue ;;
        -force_remove)         FORCE_REMOVE=$2    ; shift 2; continue ;;
        *)       BAD_OPTION $1;;
    esac
done

# Check if the read folder exists.
check_read_folder

# Function to unzip reads.
unzip_sequences

# Check if -path_output variable of input parameter is setting.
check_output_folder

echo "The number of threads : $THREAD"

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

        # Count number of reads (zcat of gzip format and cat for decompressed file )
        countReads=$(cat ${R1_FASTQ_READ} | grep '^+' | wc -l )

        # Multiply by 2 le number of R1 reads and create a info txt.
        echo $(($countReads * 2)) > ${R1_FASTQ_READ%%.*}_info.txt

        echo "Run clumpify.sh with depude flag to remove duplicate reads."
        # Clumpify which remove duplicate reads.
        clumpify.sh qin=33 \
                    in1=${R1_FASTQ_READ} \
                    in2=${READ_FILE_R2} \
                    out1=${DEDUPE_R1} \
                    out2=${DEDUPE_R2} \
                    dedupe
        echo -e "Outputs are \n$DEDUPE_R1\n$DEDUPE_R2"
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
        trimmomatic PE -threads $THREAD \
                    ${DEDUPE_R1} \
                    ${DEDUPE_R2} \
                    ${R1_FASTQ_READ%%.*}_trimmed.fastq.gz \
                    ${R1_FASTQ_READ%%.*}_unpair_trimmed.fastq.gz \
                    ${READ_FILE_R2%%.*}_trimmed.fastq.gz \
                    ${READ_FILE_R2%%.*}_unpair_trimmed.fastq.gz \
                    AVGQUAL:20 \
                    MINLEN:50
        echo -e "Trimmonatic outputs are "
        echo "Trimomonatic done !"
    else
        echo "Not paired reads."

        # Count R1 read.
        cat ${R1_FASTQ_READ} | grep '^+' | wc -l > ${R1_FASTQ_READ%%.*}.info.txt

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
        trimmomatic SE -threads $THREAD \
                    ${DEDUPE_R1} \
                    ${R1_FASTQ_READ%%.*}_trimmed.fastq.gz \
                    AVGQUAL:20 \
                    MINLEN:50
        echo -e "Trimmonatic output is \n${R1_FASTQ_READ%%.*}_trimmed.fastq.gz"
    fi
done

# List all trimmed file in current directory.
ALL_TRIMMONATIC_OUTPUTS=$(ls $FOLDER_INPUT | grep -i "_trimmed\|_unpair_trimmed")

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

echo "Move trimmed file done !"

# By default delete intermediate (dedupe) file.
if [[ $FORCE_REMOVE == "yes" ]]
then
    echo "Remove dedupe files : dedupe file to save space limit."
    rm $FOLDER_INPUT*_dedupe.fastq
else
    ALL_DEDUPE_OUTPUTS=$(ls $FOLDER_INPUT | grep -i "_dedupe")

    # Full path of dedupe reads.
    for DEDUPE_READ in $ALL_DEDUPE_OUTPUTS; do
        FULL_PATH_DEDUPE_OUTPUTS+="$FOLDER_INPUT$DEDUPE_READ "
    done

    # Move dedupe file.
    echo "Move all trimmed files in $FOLDER_OUTPUT."
    for DEDUPE_OUTPUT in $FULL_PATH_DEDUPE_OUTPUTS
    do
        mv -v $DEDUPE_OUTPUT $FOLDER_OUTPUT
    done
    echo "Move dedupe file done !"
fi
