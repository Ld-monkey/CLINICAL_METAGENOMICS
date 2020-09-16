#!/bin/bash

# DESCRIPTION 
# Run the preprocess on all reads. This action removes poor quality,
# duplicates and small reads.
#
# EXAMPLE
# e.g bash src/bash/launch_reads_preprocess.sh \
#          -path_fastq_1 data/reads/TEST/fileR1.fastq.gz \
#          -path_fastq_2 data/reads/TEST/fileR2.fastq.gz \
#          -path_output results/trimmed_reads/
#          -threads 8
#
# REQUIREMENTS
# clumpify.sh, trimmomatic, dedupe
#
# HISTORY
# 08.2020 : Zygnematophyce : launch_reads_preprocess.sh
# 08.2019 : AntoineL : launchPreprocess.sh


# Function to check if Clumpify and Trimmomatic are loaded.
function check_load_tools {
    clumpify_command=$(clumpify.sh)
    trimmomatic_command=$(trimmomatic -version)

    # Check if softwares are loaded.
    if [[ $clumpify_command ]] && [[ $trimmomatic_command ]]; then
	echo "Clumpify.sh and Trimmomatic are initialized"
    else
	echo "Error : Clumpify.sh and or Trimmomatic are not initialized !"
	echo "Install Clumpify.sh and or Trimmomatic or load a conda environment (metagenomic_env?)"
	exit 1
    fi
}


# Check if FASTQ1 parameter is set and paired.
function check_paired_sequences {
    if [ -z ${FASTQ1+x} ]; then
        echo "-path_fastq_1 is unset."
	echo "Error : if no sequence or read is specified no pre-process can be executed."
        echo "exit"
        exit 1
    else
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
    fi
}


# Function to check if the output folder is set.
function check_output_folder {
    if [ -z ${FOLDER_OUTPUT+x} ]; then
        echo "-path_output is unset"
        echo "You must specify the -path_output parameter"
        echo "exit"
        exit 1
    else
        echo "-path_output is set"
	if [ -d $FOLDER_OUTPUT ]; then
            echo "$FOLDER_OUTPUT folder already exits."
	else
            mkdir -v -p $FOLDER_OUTPUT
            echo "Create output folder $FOLDER_OUTPUT "
	fi
    fi
}


# Check if .gzip format.
function is_gzip_format {
    if [ ${FASTQ1: -3} == ".gz" ]; then
	FLAG_GZIP="True"
	echo "FLAG_GZIP = $FLAG_GZIP"
    else
	FLAG_GZIP="False"
	echo "FLAG_GZIP = $FLAG_GZIP"
    fi
}


# Get the total number of reads before preprocess.
function count_total_reads_before_preprocess {
    if [[ $FLAG_GZIP == "True" ]]; then
	# Count number of reads (zcat of gzip format and cat for decompressed file )
	countReads=$(zcat ${FASTQ1} | grep '^+' | wc -l )
    else
	countReads=$(cat ${FASTQ1} | grep '^+' | wc -l )
    fi
}


# Launch the preprocess on all reads.
function run_preprocess {

    # Create all subfolders.
    mkdir -p -v ${FOLDER_OUTPUT}trimmed/
    mkdir -p -v ${FOLDER_OUTPUT}untrimmed/
    mkdir -p -v ${FOLDER_OUTPUT}total_reads/

    # Check if gzip format.
    is_gzip_format

    # Basename of fastq R1.
    BASENAME_FASTQ1=$(basename $FASTQ1)
    echo "basename fastq1 = $BASENAME_FASTQ1"

    # Create dedupe name.
    if [[ $FLAG_GZIP = "True" ]]; then
	DEDUPE_R1=$(echo ${FASTQ1} | sed 's/.fastq.gz/_dedupe.fastq.gz/')
    else
	DEDUPE_R1=$(echo ${FASTQ1} | sed 's/.fastq/_dedupe.fastq/')
    fi

    # Check paired sequences.
    if [[ $FLAG_PAIRED_SEQUENCE = "yes" ]]; then

	echo "Paired reads exists !"

	# Basename of fastq R2.
	BASENAME_FASTQ2=$(basename $FASTQ2)
	echo "basename fastq2 = $BASENAME_FASTQ2"
       	
	# Create dedupe paired name from all reads name.
	DEDUPE_R2=$(echo ${FASTQ2} | sed 's/.fastq.gz/_dedupe.fastq.gz/')

        # Count all reads in R1 + R2 files and put number in output file.
	# Count all reads before preprocess.
	count_total_reads_before_preprocess

	# Multiply by 2 le number of R1 reads and create a info txt.
	echo $(($countReads * 2)) > ${FOLDER_OUTPUT}total_reads/${BASENAME_FASTQ1%%.*}_before_preprocess_info.txt

        echo "Run clumpify.sh with depude flag to remove duplicate reads."
	
        # Clumpify simply re-orders it to maximize gzip compression.
	# With dedupe option can remove duplicate reads.
        clumpify.sh qin=33 \
		    in1=${FASTQ1} \
		    in2=${FASTQ2} \
		    out1=${DEDUPE_R1} \
		    out2=${DEDUPE_R2} \
		    dedupe
	
        echo -e "Outputs are \n$DEDUPE_R1\n$DEDUPE_R2"

        echo "Run Trimmomatic to remove poor quality and small reads"	    
        # Using Trimmomatic a java program to remove poor quality of reads
        # not lower that 20 and too small reads not smaller that 50 nucleotides.
        # From Manual of Trimmomatic :
	# https://datacarpentry.org/wrangling-genomics/03-trimming/
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
		    ${FOLDER_OUTPUT}trimmed/${BASENAME_FASTQ1%%.*}_trimmed.fastq.gz \
		    ${FOLDER_OUTPUT}untrimmed/${BASENAME_FASTQ1%%.*}_unpair_trimmed.fastq.gz \
		    ${FOLDER_OUTPUT}trimmed/${BASENAME_FASTQ2%%.*}_trimmed.fastq.gz \
		    ${FOLDER_OUTPUT}untrimmed/${BASENAME_FASTQ2%%.*}_unpair_trimmed.fastq.gz \
		    AVGQUAL:20 \
		    MINLEN:50
	
        echo -e "Trimmomatic outputs are \n${FASTQ1%%.*}_trimmed.fastq.gz\n${FASTQ1%%.*}_unpair_trimmed.fastq.gz\n${FASTQ2%%.*}_trimmed.fastq.gz\n${FASTQ2%%.*}_unpair_trimmed.fastq.gz"
        echo "Trimomonatic done !"

	# Count trimmed read after preprocess.
	countReads=$(zcat ${FOLDER_OUTPUT}trimmed/${BASENAME_FASTQ1%%.*}_trimmed.fastq.gz | grep '^+' | wc -l )

	# Multiply by 2 le number of R1 reads and create a info txt.
	echo $(($countReads * 2)) > ${FOLDER_OUTPUT}total_reads/${BASENAME_FASTQ1%%.*}_post_preprocess_info.txt
    else
	echo "Not paired reads."

	# Count all reads in R1 and put number in output file.
	total_reads=$(count_total_reads_before_preprocess)
	echo "$total_reads" > ${FOLDER_OUTPUT}total_reads/${BASENAME_FASTQ1%%.*}_before_preprocess_info.txt

        echo "Run clumpify.sh to remove duplicate reads."
	
        # Clumpify which remove duplicate reads.
        clumpify.sh qin=33 \
		    in=${FASTQ1} \
		    out=${DEDUPE_R1} \
		    dedupe
	
        echo -e "Clumpify.sh outputs are \n$DEDUPE_R1\n$DEDUPE_R2"

        echo "Run Trimmomatic to remove poor quality and small reads"
	
        # Using Trimmomatic to remove poor quality and too small reads.
        # From Manual of Trimmomatic :
	# https://datacarpentry.org/wrangling-genomics/03-trimming/
        # <inputFile1> 	Input reads to be trimmed.
        #     Typically the file name will contain an _1 or _R1 in the name.
        # <outputFile1P> 	Output file that contains surviving pairs from the _1 file.
	
        trimmomatic SE -threads $THREAD \
		    ${DEDUPE_R1} \
		    ${FOLDER_OUTPUT}trimmed/${BASENAME_FASTQ1%%.*}_trimmed.fastq.gz \
		    AVGQUAL:20 \
		    MINLEN:50
	
        echo -e "Trimmomatic output is \n${FASTQ1%%.*}_trimmed.fastq.gz"
	
	# Count trimmed read after preprocess.
	countReads=$(zcat ${FOLDER_OUTPUT}trimmed/${BASENAME_FASTQ1%%.*}_trimmed.fastq.gz | grep '^+' | wc -l )

	# Multiply by 2 le number of R1 reads and create a info txt.
	echo $(($countReads * 2)) > ${FOLDER_OUTPUT}total_reads/${BASENAME_FASTQ1%%.*}_post_preprocess_info.txt
    fi
}


# Remove all intermediates files.
function remove_intermediate_files {

    # By default delete intermediate (dedupe) file.
    if [[ $FORCE_REMOVE == "yes" ]]; then
	echo "Remove dedupe files : dedupe file to save space limit."
	rm -rf --verbose ${FOLDER_INPUT}*_dedupe*
    else
	echo "Intermediate files are not deleted."
    fi
}


# Move dedupe files.
function move_dedupe_files {

    # Create an appropriate folder.
    mkdir -p -v ${FOLDER_OUTPUT}dedupe/
    
    # Move all dedupe files
    ALL_DEDUPE_OUTPUTS=$(ls $FOLDER_INPUT | grep -i "_dedupe")

    # Full path of dedupe reads.
    for DEDUPE_READ in $ALL_DEDUPE_OUTPUTS; do
	FULL_PATH_DEDUPE_OUTPUTS+="$FOLDER_INPUT$DEDUPE_READ "
    done

    # Move dedupe file.
    echo "Move all trimmed files in $FOLDER_OUTPUT."
    
    for DEDUPE_OUTPUT in $FULL_PATH_DEDUPE_OUTPUTS; do
	mv -v $DEDUPE_OUTPUT ${FOLDER_OUTPUT}dedupe/
    done
    
    echo "Move dedupe file done !"
}


PROGRAM=launch_reads_preprocess.sh
VERSION=1.0

DESCRIPTION=$(cat << __DESCRIPTION__

__DESCRIPTION__
           )

OPTIONS=$(cat << __OPTIONS__

## OPTIONS ##
    -path_fastq_1    (Input)     The path of the sequence or read in fastq format.                                   *FILE: data/reads/fileR1.fastq
    -path_fastq_2    (Optional)  The path of the sequence or read in pairs in fastq format.                          *FILE: data/reads/fileR2.fastq
    -path_output     (output)    The folder of output reads trimmed.                                                  *DIR: output_reads_trimmed
    -threads         (Input)     The number of thread.                                                                *INT: 6
    -force_remove    (Optional)  By default the value is yes and allows you to delete intermediate files.           *STR: yes|no
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
    echo "example : bash src/bash/launch_reads_preprocess.sh -path_fastq_1 data/reads/TEST/fileR1.fastq.gz -path_fastq_2 data/reads/TEST/fileR2.fastq.gz -path_output results/trimmed_reads/trimmed_PAIRED_SAMPLES_ADN_TEST_reads_04_06_2020/ -threads 28"
    echo -e $USAGE

    exit 1
}

# Check options
while [ -n "$1" ]; do
    case $1 in
        -h)                    USAGE      ; exit 0 ;;
        -path_fastq_1)         FASTQ1=$2          ; shift 2; continue ;;
        -path_fastq_2)         FASTQ2=$2          ; shift 2; continue ;;
	-path_output)          FOLDER_OUTPUT=$2   ; shift 2; continue ;;
        -threads)              THREAD=$2          ; shift 2; continue ;;
        -force_remove)         FORCE_REMOVE=$2    ; shift 2; continue ;;
        *)       BAD_OPTION $1;;
    esac
done

echo "FASTQ1 : $FASTQ1"
echo "FASTQ2 : $FASTQ2"
echo "folder output : $FOLDER_OUTPUT"

# Check Clumpify and Trimmomatic are loaded.
check_load_tools

# Check if paired or not sequences.
check_paired_sequences

# Check if -path_ variable of input parameter is setting.
check_output_folder

echo "The number of threads : $THREAD"

# Launch the preprocess on all reads.
run_preprocess

# By default remove intermediate files.
if [[ $FORCE_REMOVE == "yes" ]]; then
    
    # Remove all intermediate files.
    remove_intermediate_files&
else
    echo "Intermediate files are not deleted."

    # Move dedupe files.
    move_dedupe_files&
fi
