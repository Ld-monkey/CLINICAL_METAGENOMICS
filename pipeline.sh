#!/bin/bash

# project architecture :
#
# results/
# ├── {DATE}/
#     ├── all_plots
#     ├── all_reports
#     ├── post_blast_classification
#     ├── convert_fastq_to_fasta
#     ├── filtered_sequences
#     ├── kraken2_classification
#     ├── same_taxonomics_id_kraken_blast
#     └── trimmed_reads


# Create root architecture directory with specific name and date.
function create_root_architecture {
    if [ -d "$ROOT_RESULTS" ]; then
	echo "$ROOT_RESULTS already exists."
    else
	mkdir -p --verbose $ROOT_RESULTS
    fi
}


# Check if paired reads.
function check_paired_reads {
    if [[ -f "$READ" ]] && [[ -f "$PAIRED_READS" ]]; then
	echo "Paired sequences"
	# Create a FLAG
	FLAG_PAIRED_SEQUENCE="True"
	echo "R1 : $READ"
	echo "R2 : $PAIRED_READS"
    else
	echo "No paired sequences"
	# Create a FLAG
	FLAG_PAIRED_SEQUENCE="False"
	echo "R1 : $READ"
    fi    
}


# Run the preprocess on all reads.
function run_preprocess_all_reads {
    if [[ $FLAG_PAIRED_SEQUENCE = "True" ]]; then
	bash src/bash/launch_reads_preprocess.sh \
	     -path_fastq_1 $READ \
	     -path_fastq_2 $PAIRED_READS \
	     -path_output  $ROOT_RESULTS$PREPROCESS_FOLDER${BASENAME_PROJECT}/ \
	     -threads $THREADS
    else
	bash src/bash/launch_reads_preprocess.sh \
	     -path_fastq_1 $READ \
	     -path_output  $ROOT_RESULTS$PREPROCESS_FOLDER${BASENAME_PROJECT}/ \
	     -threads $THREADS
    fi
}


# Classification with Kraken 2.
function kraken2_classification {
    bash src/bash/classify_set_reads_kraken.sh \
	 -path_reads $ROOT_RESULTS$PREPROCESS_FOLDER${BASENAME_PROJECT}/trimmed/ \
	 -path_db data/databases/kraken_2/fda_argos_database_none_library_25_08_2020/ \
	 -path_output $ROOT_RESULTS$KRAKEN2_DIRECTORY${BASENAME_PROJECT}/ \
	 -threads $THREADS
}


# Convert fastq to fasta for blast algorithm.
function convert_fastq_to_fasta {
    FASTQ1_R1=$(ls $ROOT_RESULTS$KRAKEN2_DIRECTORY${BASENAME_PROJECT}/classified/ | grep "clseqs_1")
    OUTPUT_FASTA=$(echo ${FASTQ1_R1} | sed "s/.clseqs_1/_conversion/" )
    OUTPUT_FASTA=$(echo "${OUTPUT_FASTA%%.*}".fasta)

    if [[ $FLAG_PAIRED_SEQUENCE = "True" ]]; then
	FASTQ2_R2=$(echo ${FASTQ1_R1} | sed "s/clseqs_1/clseqs_2/" )
	
	echo $FASTQ1_R1
	echo $FASTQ2_R2
	echo $OUTPUT_FASTA

	bash src/bash/convert_fastq_to_fasta.sh \
	     -path_fastq_1 $ROOT_RESULTS$KRAKEN2_DIRECTORY${BASENAME_PROJECT}/classified/$FASTQ1_R1 \
	     -path_fastq_2 $ROOT_RESULTS$KRAKEN2_DIRECTORY${BASENAME_PROJECT}/classified/$FASTQ2_R2 \
	     -output_fasta $ROOT_RESULTS$FASTQ_TO_FASTA${BASENAME_PROJECT}/$OUTPUT_FASTA
    else
	bash src/bash/convert_fastq_to_fasta.sh \
	     -path_fastq_1 $ROOT_RESULTS$KRAKEN2_DIRECTORY${BASENAME_PROJECT}/classified/$FASTQ1_R1 \
	     -output_fasta $ROOT_RESULTS$FASTQ_TO_FASTA${BASENAME_PROJECT}/$OUTPUT_FASTA
    fi
}


# Classification with blast.
function blast_classification {
    bash src/bash/classify_set_reads_blast.sh \
	 -path_seq $ROOT_RESULTS$FASTQ_TO_FASTA${BASENAME_PROJECT}/$OUTPUT_FASTA \
	 -path_db data/databases/blast/fda_argos_blast_database_27_08_2020/ \
	 -path_output $ROOT_RESULTS$BLAST_DIRECTORY${BASENAME_PROJECT}/ \
	 -threads $THREADS
}


# Find same taxonomics ID.
function find_same_taxonomics_id {
    BLAST_FILE=$(ls $ROOT_RESULTS$BLAST_DIRECTORY${BASENAME_PROJECT}/)
    python3 src/python/get_all_taxonomic_ids_same_genus_blast_kraken.py \
	    -path_blast $ROOT_RESULTS$BLAST_DIRECTORY${BASENAME_PROJECT}/$BLAST_FILE \
	    -output $ROOT_RESULTS$SAME_TAXONOMICS${BASENAME_PROJECT}/conserved.txt    
}


# Filter according to the sequences classified by kraken.
function fitered_sequences_same_rank {
    bash src/bash/find_sequences_filtered_same_rank.sh \
	 -path_classified $ROOT_RESULTS$KRAKEN2_DIRECTORY${BASENAME_PROJECT}/classified/ \
	 -path_conserved $ROOT_RESULTS$SAME_TAXONOMICS${BASENAME_PROJECT}/conserved.txt \
	 -path_output $ROOT_RESULTS$FILTERED_SEQUENCES${BASENAME_PROJECT}/
}


# Create a sequencing coverage of each reads.
function sequencing_coverage {
    python3 src/python/create_coverage_plot.py \
	    -path_counter $ROOT_RESULTS$SAME_TAXONOMICS${BASENAME_PROJECT}/countbis.txt \
	    -path_conserved $ROOT_RESULTS$SAME_TAXONOMICS${BASENAME_PROJECT}/conserved_sorted.txt \
	    -path_plot $ROOT_RESULTS$PLOT_COVERAGE${BASENAME_PROJECT}/
}


# Create all html reports.
function create_html_reports {
    BEFORE_PREPROCESS=$(ls $ROOT_RESULTS$PREPROCESS_FOLDER${BASENAME_PROJECT}/total_reads/*before_preprocess_info.txt)
    AFTER_PREPROCESS=$(ls $ROOT_RESULTS$PREPROCESS_FOLDER${BASENAME_PROJECT}/total_reads/*post_preprocess_info.txt)
    REPORT_KRAKEN2=$(ls $ROOT_RESULTS$KRAKEN2_DIRECTORY${BASENAME_PROJECT}/*.report.txt)
    SUMMARY_FILE=$(ls $ROOT_RESULTS$SAME_TAXONOMICS${BASENAME_PROJECT}/summary.txt)

    echo "before preprocess $BEFORE_PREPROCESS"
    echo "after preprocess  $AFTER_PREPROCESS"
    echo "report.txt : $REPORT_KRAKEN2"
    echo "summary : $SUMMARY_FILE"

    python3 src/report/create_html_report_test.py \
    	    -name_object ${BASENAME_PROJECT} \
    	    -before_preprocess $BEFORE_PREPROCESS \
    	    -after_preprocess $AFTER_PREPROCESS \
    	    -path_report $REPORT_KRAKEN2 \
    	    -path_summary $SUMMARY_FILE \
    	    -path_template src/report/templates/datatables_report_test.html \
    	    -path_output $ROOT_RESULTS$ALL_REPORTS${BASENAME_PROJECT}/
}


PROGRAM=pipeline.sh
VERSION=1.0

DESCRIPTION=$(cat << __DESCRIPTION__

__DESCRIPTION__
           )

OPTIONS=$(cat << __OPTIONS__

## OPTIONS ##
    -path_reads   (Input)     The path with the reads.                                  *DIR: data/reads/GZIP_PAIRED_ADN/
    -name_project (Optional)  Defines a name for the project.                           *STR: patient_1_
__OPTIONS__
       )

# default options:
NAME_PROJECT=""
THREADS=8

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
    echo "e.g bash pipeline.sh -path_reads data/reads/GZIP_PAIRED_ADN/"
    echo -e $USAGE

    exit 1
}

# Check options
while [ -n "$1" ]; do
    case $1 in
        -h)                    USAGE      ; exit 0 ;;
        -path_reads)        PATH_READS=$2   ; shift 2; continue ;;
	-name_project)      NAME_PROJECT=$2 ; shift 2; continue ;;
	-threads)           THREADS=$2      ; shift 2; continue ;;
        *)       BAD_OPTION $1;;
    esac
done

DATE=$(date +"%d_%m_%Y_%Hh_%Mm_%Ss")
ROOT_RESULTS="results/${NAME_PROJECT}${DATE}/"

echo "Results in $ROOT_RESULTS"

# Create root architecture.
create_root_architecture

# List all 
ALL_BASENAME_READS=$(ls $PATH_READS -1 | sort | grep "R1")

# Concatenation to get full path of reads.
for NAME_READS in $ALL_BASENAME_READS; do
    FULL_PATH_READS+="$PATH_READS$NAME_READS "
done

# Main loop.
for READ in $FULL_PATH_READS; do

    # Create a basename of sub-project.
    BASENAME_PROJECT=$(basename $READ)
    BASENAME_PROJECT=${BASENAME_PROJECT%%.*}

    # Create a creation of a putative name file.
    PAIRED_READS=$(echo ${READ} | sed 's/R1/R2/')

    # Check if read is paired.
    check_paired_reads
   
    # Run the preprocess on all reads.
    PREPROCESS_FOLDER="trimmed_reads/"
    run_preprocess_all_reads

    # Create Kraken 2 classification.
    KRAKEN2_DIRECTORY="kraken2_classification/"
    kraken2_classification

    # Convert fastq to fasta.
    FASTQ_TO_FASTA="convert_fastq_to_fasta/"
    convert_fastq_to_fasta

    # Create blast classification.
    BLAST_DIRECTORY="post_blast_classification/"
    blast_classification

    # find same taxonomic ID from Kraken 2 and blast classifications.
    SAME_TAXONOMICS="same_taxonomics_id_kraken_blast/"
    find_same_taxonomics_id

    # Filter according to the sequences classified by Kraken 2.
    FILTERED_SEQUENCES="filtered_sequences/"
    fitered_sequences_same_rank

    # Create a sequencing coverage of each reads.
    PLOT_COVERAGE="all_plots/"
    sequencing_coverage

    # Create all html reports.
    ALL_REPORTS="all_reports/"
    create_html_reports
done
