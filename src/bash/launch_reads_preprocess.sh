#!/bin/bash

# Launch pre-process on reads. This action removes poor quality,
# duplicates and small reads. (Old name => launch_preprocess.sh)
# e.g bash src/bash/launch_reads_preprocess.sh \
#          -path_reads data/reads/PAIRED_SAMPLES_ADN_TEST/ \
#          -path_output results/trimmed_reads/trimmed_PAIRED_SAMPLES_ADN_TEST_reads_04_06_2020/
#          -threads 28


# Function to check if Clumpify and Trimmomatic are loaded.
function check_load_tools {

    clumpify_command=$(clumpify.sh)
    trimmomatic_command=$(trimmomatic -version)

    # Check is result is load.
    if [[ $clumpify_command ]] && [[ $trimmomatic_command ]]; then
	echo "Clumpify.sh and Trimmomatic are initialized"
    else
	echo "Error : Clumpify.sh and or Trimmomatic are not initialized !"
	echo "Install Clumpify.sh and or Trimmomatic or load a conda environment with Kraken 2 (metagenomic_env?)"
	exit 1
    fi
}


# Function to check if the read folder exists.
function check_read_folder {

    # Check if parameter is set. 
    if [ -z ${FOLDER_INPUT+x} ]; then
        echo "-path_reads is unset."
        echo "exit"
        exit 1
    else
        if [ -d ${FOLDER_INPUT} ]
        then
            echo $FOLDER_INPUT
            echo "$FOLDER_INPUT folder of read exist."
        else
            echo "Error $FOLDER_INPUT doesn't exist."
            exit 1
        fi
    fi
}


# Function to check if the output folder is set.
function check_output_folder {

    # Check if parameter is set.
    if [ -z ${FOLDER_OUTPUT+x} ]; then
        echo "-path_output is unset"
        echo "You must specify the -path_output parameter"
        echo "exit"
        exit 1
    else
        echo "-path_output is set"

        # Check the output folder.
        check_output_folder
    fi
}


# Function to check if the output folder exists.
function check_output_folder {
    if [ -d $FOLDER_OUTPUT ]; then
        echo "$FOLDER_OUTPUT folder already exits."
    else
        mkdir -v -p $FOLDER_OUTPUT
        echo "Create output folder $FOLDER_OUTPUT "
    fi
}


# Get the full correct path of sequences.
function get_full_path_sequences {

    # List all R1*fastq files.
    ALL_R1_FASTQ_READS=$(ls $FOLDER_INPUT | grep -i R1.*\.fastq)

    # Full path of reads.
    for R1_READ in $ALL_R1_FASTQ_READS; do
	FULL_PATHS_ALL_R1_READS+="$FOLDER_INPUT$R1_READ "
    done
}


# Check if .gzip format.
function is_gzip_format {
    if [ ${R1_FASTQ_READ: -3} == ".gz" ]; then
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
	countReads=$(zcat ${R1_FASTQ_READ} | grep '^+' | wc -l )
    else
	countReads=$(cat ${R1_FASTQ_READ} | grep '^+' | wc -l )
    fi
}


# Get the total number of reads after preprocess.
function count_total_reads_after_preprocess {
    # Count number of reads (zcat of gzip format and cat for decompressed file )
    countReads=$(zcat ${R1_FASTQ_READ%%.*}_trimmed.fastq.gz | grep '^+' | wc -l )
}


# Trimmed all sequences.
function trimmed_sequences {

    # Get full path of R1 sequences in FULL_PATHS_ALL_R1_READS variable.
    get_full_path_sequences

    # For all reads in the folder.
    for R1_FASTQ_READ in $FULL_PATHS_ALL_R1_READS; do

	# Check if gzip format.
	is_gzip_format
	
	# Create a R2 read name file to check if paired read exists.
	R2_FASTQ_READ=$(echo ${R1_FASTQ_READ} | sed 's/R1/R2/')

	# Create output dedupe name from all reads name for dedupe process.
	DEDUPE_R1=$(echo ${R1_FASTQ_READ} | sed 's/R1/R1_dedupe/')
	DEDUPE_R2=$(echo ${R1_FASTQ_READ} | sed 's/R1/R2_dedupe/')

	# Check if paired (R2) reads exists.
	if [ -f "${R2_FASTQ_READ}" ]
	then
            echo "Paired reads exists !"

	    # Count all reads in R1 + R2 files and put number in output file.
	    # Count all reads before preprocess.
	    count_total_reads_before_preprocess

	    # Multiply by 2 le number of R1 reads and create a info txt.
	    echo $(($countReads * 2)) > ${R1_FASTQ_READ%%.*}_before_preprocess_info.txt

            echo "Run clumpify.sh with depude flag to remove duplicate reads."
	    
            # Clumpify simply reorders it to maximize gzip compression.
	    # With dedupe option can remove duplicate reads.
            clumpify.sh qin=33 \
			in1=${R1_FASTQ_READ} \
			in2=${R2_FASTQ_READ} \
			out1=${DEDUPE_R1} \
			out2=${DEDUPE_R2} \
			dedupe
	    
            echo -e "Outputs are \n$DEDUPE_R1\n$DEDUPE_R2"
            echo "Remove duplicated reads done !"

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
			${R1_FASTQ_READ%%.*}_trimmed.fastq.gz \
			${R1_FASTQ_READ%%.*}_unpair_trimmed.fastq.gz \
			${R2_FASTQ_READ%%.*}_trimmed.fastq.gz \
			${R2_FASTQ_READ%%.*}_unpair_trimmed.fastq.gz \
			AVGQUAL:20 \
			MINLEN:50
	    
            echo -e "Trimmomatic outputs are \n${R1_FASTQ_READ%%.*}_trimmed.fastq.gz\n${R1_FASTQ_READ%%.*}_unpair_trimmed.fastq.gz\n${R2_FASTQ_READ%%.*}_trimmed.fastq.gz\n${R2_FASTQ_READ%%.*}_unpair_trimmed.fastq.gz"
            echo "Trimomonatic done !"

	    # Count all trimmed reads after preprocess.
	    count_total_reads_after_preprocess

	    # Multiply by 2 le number of R1 reads and create a info txt.
	    echo $(($countReads * 2)) > ${R1_FASTQ_READ%%.*}_post_preprocess_info.txt
	else
	    
            echo "Not paired reads."

	    # Count all reads in R1 and put number in output file.
	    total_reads=$(count_total_reads_before_preprocess)
	    echo "$total_reads" > ${R1_FASTQ_READ%%.*}_before_preprocess_info.txt

            echo "Run clumpify.sh to remove duplicate reads."
	    
            # Clumpify which remove duplicate reads.
            clumpify.sh qin=33 \
			in=${R1_FASTQ_READ} \
			out=${DEDUPE_R1} \
			dedupe
	    
            echo -e "Clumpify.sh outputs are \n$DEDUPE_R1\n$DEDUPE_R2"
            echo "Remove duplicated reads done !"

            echo "Run Trimmomatic to remove poor quality and small reads"
	    
            # Using Trimmomatic to remove poor quality and too small reads.
            # From Manual of Trimmomatic :
	    # https://datacarpentry.org/wrangling-genomics/03-trimming/
            # <inputFile1> 	Input reads to be trimmed.
            #     Typically the file name will contain an _1 or _R1 in the name.
            # <outputFile1P> 	Output file that contains surviving pairs from the _1 file.
	    
            trimmomatic SE -threads $THREAD \
			${DEDUPE_R1} \
			${R1_FASTQ_READ%%.*}_trimmed.fastq.gz \
			AVGQUAL:20 \
			MINLEN:50
	    
            echo -e "Trimmomatic output is \n${R1_FASTQ_READ%%.*}_trimmed.fastq.gz"
	    
	    # Count all reads after preprocess.
	    count_total_reads_after_preprocess
	    echo "$countReads" > ${R1_FASTQ_READ%%.*}_after_preprocess_info.txt
	fi
    done    
}


# Move trimmed files.
function move_trimmed_files {
    
    # List all trimmed file in current directory.
    ALL_TRIMMONATIC_OUTPUTS=$(ls $FOLDER_INPUT \
				  | grep -i "_trimmed\|_unpair_trimmed")

    # Full path of trimmed reads.
    for TRIMMED_READ in $ALL_TRIMMONATIC_OUTPUTS; do
	FULL_PATH_TRIMMONATIC_OUTPUTS+="$FOLDER_INPUT$TRIMMED_READ "
    done

    echo "Move all trimmed files in $FOLDER_OUTPUT."
    for TRIMMONATIC_OUTPUT in $FULL_PATH_TRIMMONATIC_OUTPUTS; do
	mv -v $TRIMMONATIC_OUTPUT $FOLDER_OUTPUT
    done

    echo "Move trimmed file done !"
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
    
    # Move all dedupe files
    ALL_DEDUPE_OUTPUTS=$(ls $FOLDER_INPUT | grep -i "_dedupe")

    # Full path of dedupe reads.
    for DEDUPE_READ in $ALL_DEDUPE_OUTPUTS; do
	FULL_PATH_DEDUPE_OUTPUTS+="$FOLDER_INPUT$DEDUPE_READ "
    done

    # Move dedupe file.
    echo "Move all trimmed files in $FOLDER_OUTPUT."
    
    for DEDUPE_OUTPUT in $FULL_PATH_DEDUPE_OUTPUTS; do
	mv -v $DEDUPE_OUTPUT $FOLDER_OUTPUT
    done
    
    echo "Move dedupe file done !"
}


# Move info.txt that contain the total of reads.
function move_info_total_reads {

    # Create a specific folder for info.
    mkdir -p -v ${FOLDER_OUTPUT}info

    # Move info.txt
    ALL_INFO_OUTPUTS=$(ls $FOLDER_INPUT | grep -i "_info.txt")

    # Full path of info txt.
    for INFO in $ALL_INFO_OUTPUTS; do
	FULL_PATH_INFO_OUTPUTS+="$FOLDER_INPUT$INFO "
    done
    
    # Move all info files.
    echo "Move all info files in $FOLDER_OUTPUT."
    for INFO_OUTPUT in $FULL_PATH_INFO_OUTPUTS; do
	mv -v $INFO_OUTPUT ${FOLDER_OUTPUT}info
    done
    
    echo "Move info files done !"
}


PROGRAM=launch_reads_preprocess.sh
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
    echo "example : bash src/bash/launch_reads_preprocess.sh -path_reads data/reads/PAIRED_SAMPLES_ADN_TEST/ -path_output results/trimmed_reads/trimmed_PAIRED_SAMPLES_ADN_TEST_reads_04_06_2020/ -threads 28"

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

# Check Clumpify and Trimmomatic are loaded.
check_load_tools

# Check if the read folder exists.
check_read_folder

# Check if -path_output variable of input parameter is setting.
check_output_folder

echo "The number of threads : $THREAD"

# Trimmed all sequences.
trimmed_sequences

# Move trimmed file.
move_trimmed_files

# Move info.txt.
move_info_total_reads

# By default remove intermediate files.
if [[ $FORCE_REMOVE == "yes" ]]; then
    
    # Remove all intermediate files.
    remove_intermediate_files&
else
    echo "Intermediate files are not deleted."

    # Move dedupe files.
    move_dedupe_files&
fi
