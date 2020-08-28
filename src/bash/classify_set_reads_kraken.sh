#!/bin/bash

# From a set of reads and depend of the database gived in argument allow to
# classify the reads sequences. (Warning : paired sequence must named *R1*.fastq).
# e.g bash src/bash/classify_set_reads_kraken.sh \
#          -path_reads results/trimmed_reads/trimmed_PAIRED_SAMPLES_READS/ \
#          -path_db data/databases/kraken_2/fda_argos_with_none_library_kraken_database \
#          -path_output results/classify_reads/trimmed_classify_fda_argos \
#          -threads 8


# Check is Kraken 2 is load.
function check_load_kraken {

    # Check is result is load.
    if kraken2-build --version; then
	echo "Kraken 2 is initialized."
    else
	echo "Error : Kraken 2 is not initialized !"
	echo "Install Kraken 2 or load a conda environment with Kraken 2 (metagenomic_env?)"
	exit 1
    fi
}


# Function to check if the sequence folder exists.
function check_sequence_folder {

    # Check if parameter is set.
    if [ -z ${PATH_ALL_READS+x} ]
    then
        echo "-path_reads unset."
        echo "The program cannot work if it has no sequences to classify !"
	exit 1
    else
        if [ -d ${PATH_ALL_READS} ]
        then
            echo $PATH_ALL_READS
            echo "$PATH_ALL_READS folder of sequence exist."
        else
            echo "Error $PATH_ALL_READS folder doesn't exist."
	    echo "The program cannot work if no folder exists with no sequences !"
            exit 1
        fi
    fi
}


# Function to check if the sequence folder exists.
function check_database_folder {

    # Check if parameter is set.
    if [ -z ${DBNAME+x} ]
    then
        echo "-path_db unset."
        echo "No classification can be done without a reference database"
	exit 1
    else
        if [ -d ${DBNAME} ]
        then
            echo $DBNAME
            echo "$DBNAME folder of Kraken 2 database exists."
        else
	    echo "Error $DBNAME folder doesn't exists."
	    echo "No classification can be done without a reference database"
            exit 1
        fi
    fi
}


# Function to check if output folder already exists.
function check_output_folder {

    # Check if parameter is set.
    if [ -z ${FOLDER_OUTPUT+x} ]
    then
        echo "-path_output is unset."
        echo "The output path for the classification results must be specified !"
	exit 1
    else
        if [ -d ${FOLDER_OUTPUT} ]
        then
            echo $FOLDER_OUTPUT
            echo "Error : $FOLDER_OUTPUT folder already exists."
	    exit 1
        else
	    echo "Create folder $FOLDER_OUTPUT "
	    mkdir -p -v $FOLDER_OUTPUT
        fi
    fi
}


# Function to determinate if .gz format.
function check_gzip_format {
    if [ ${R1_READ: -3} == ".gz" ]; then
	FLAG_GZIP="True"
    else
	FLAG_GZIP="False"
    fi
}


# Function to display some information about parameters.
function display_info_parameters {

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
}


# Launch classification with Kraken 2.
function run_classification_kraken2 {
    
    # Classify a set of sequences or reads with kraken2 tool.
    echo "Run classify a set of sequences with kraken 2"
    for R1_READ in $ALL_SURVIVORS_READS; do

	# Check if gzip format.
	check_gzip_format

	# Get prefix name for outputs.
	prefix=$(basename "$R1_READ" | awk -F "_R1" '{print $1}')

	# Create sub directory.
	mkdir -p ${FOLDER_OUTPUT}${prefix}/

	# Create a R2 read name file to check if paired read exists.
	R2_PAIRED_READ=$(echo ${R1_READ} | sed 's/R1/R2/')

	# All info about parameters.
	display_info_parameters

	# Check if paired (R2) reads exists.
	if [ -f "${R2_PAIRED_READ}" ]
	then
            echo "Paired reads exists !"

	    if [[ $FLAG_GZIP == "True" ]]; then
		echo "gzip format"
		echo "Run kraken 2 classification reads."
		
		# Official documentation : https://github.com/DerrickWood/kraken2/wiki/Manual
		# --db : specific kraken 2 database.
		# --threads : NUM switch to use multiple threads.
		# --paired : Indicate to kraken2 that the input files provided are paired read data.
		# --gzip-compressed : Input files are compressed with gzip
		# --report : format is tab-delimited with one line per taxon.
		# --classified-out, --unclassified-out : classified or unclassified sequences.
		# --output : summmary output.
		# input R1_paired_read file.
		# input R2_paired_read file.
		
		kraken2 --db $DBNAME \
			--threads $THREAD \
			--paired \
			--gzip-compressed \
			--report ${FOLDER_OUTPUT}${prefix}/${prefix}_taxon.report.txt \
			--classified-out ${FOLDER_OUTPUT}${prefix}/$prefix.clseqs#.fastq.gz \
			--unclassified-out ${FOLDER_OUTPUT}${prefix}/$prefix.unclseq#.fastq.gz \
			--output ${FOLDER_OUTPUT}${prefix}/$prefix.output.txt \
			$R1_READ $R2_PAIRED_READ
		
		echo "Kraken 2 classification done !"
	    else
		echo "No gzip format"
		
		kraken2 --db $DBNAME \
			--threads $THREAD \
			--paired \
			--report ${FOLDER_OUTPUT}${prefix}/${prefix}_taxon.report.txt \
			--classified-out ${FOLDER_OUTPUT}${prefix}/$prefix.clseqs#.fastq \
			--unclassified-out ${FOLDER_OUTPUT}${prefix}/$prefix.unclseq#.fastq \
			--output ${FOLDER_OUTPUT}${prefix}/$prefix.output.txt \
			$R1_READ $R2_PAIRED_READ
		
		echo "Kraken 2 classification done !"
	    fi
	else
            echo "Not paired reads."
	    
	    if [[ $FLAG_GZIP == "True" ]]; then
		echo "gzip format"

		echo "Run kraken 2 classification reads."
		
		Run kraken 2 classification on no paired read.
		kraken2 --db $DBNAME \
			--threads $THREAD \
			--gzip-compressed \
			--report $FOLDER_OUTPUT/${prefix}_taxon.report.txt \
			--classified-out $FOLDER_OUTPUT/$prefix.clseqs#.fastq.gz \
			--unclassified-out $FOLDER_OUTPUT/$prefix.unclseq#.fastq.gz \
			--output $FOLDER_OUTPUT/$prefix.output.txt \
			$R1_READ
		
		echo "Kraken 2 classification done !"
	    else
		echo "No gzip format"

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
	fi
    done
}


PROGRAM=classify_set_reads_kraken.sh
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
threads=8

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
    echo "example : bash src/bash/classify_set_reads_kraken.sh -path_reads results/trimmed_reads/trimmed_PAIRED_SAMPLES_ADN_TEST_reads_01_07_2020/ -path_db data/databases/kraken_2/fda_argos_with_none_library_kraken_database_07_06_2020/ -path_output results/classify_reads/trimmed_classify_fda_argos_with_none_library_02_07_2020/ -threads 8"
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

# Check if Kraken 2 is load.
check_load_kraken

# Check if sequences folder is set.
check_sequence_folder

# Check if Kraken 2 is set.
check_database_folder

# Check output folder.
check_output_folder

echo "The number of threads : $THREAD"

# List only all trimmed reads files We do not take the files that did not
# meet the trimmed conditions (unpair_trimmed) or the dedupe files (_dedupe).
ALL_SURVIVORS_READS=$(ls $PATH_ALL_READS*R1* | grep -i --invert-match "_unpair_trimmed\|_dedupe")
echo "All survivors : $ALL_SURVIVORS_READS"

# Launch classification with Kraken 2.
run_classification_kraken2
