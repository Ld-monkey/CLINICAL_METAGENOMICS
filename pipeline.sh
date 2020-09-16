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


# Run the preprocess on all reads.
function run_preprocess_all_reads {
    if [[ $FLAG_PAIRED_SEQUENCE = "True" ]]; then
	bash src/bash/launch_reads_preprocess.sh \
	     -path_fastq_1 $READ \
	     -path_fastq_2 $PAIRED_READS \
	     -path_output  $ROOT_RESULTS$PREPROCESS_FOLDER${BASENAME_PROJECT}/ \
	     -threads 8
    else
	bash src/bash/launch_reads_preprocess.sh \
	     -path_fastq_1 $READ \
	     -path_output  $ROOT_RESULTS$PREPROCESS_FOLDER${BASENAME_PROJECT}/ \
	     -threads 8
    fi
}


# Classification with Kraken 2.
function kraken2_classification {
    bash src/bash/classify_set_reads_kraken.sh \
	 -path_reads $ROOT_RESULTS$PREPROCESS_FOLDER${BASENAME_PROJECT}/trimmed/ \
	 -path_db data/databases/kraken_2/fda_argos_database_none_library_25_08_2020/ \
	 -path_output $ROOT_RESULTS$KRAKEN2_DIRECTORY${BASENAME_PROJECT}/ \
	 -threads 8
}


# Convert fastq to fasta for blast algorithm.
function convert_fastq_to_fasta {
    bash src/bash/convert_fastq_to_fasta.sh \
	 -path_fastq_1 $ROOT_RESULTS${KRAKEN2_DIRECTORY}/${READ_FOLDER}/classified/$FASTQ1_R1 \
	 -path_fastq_2 $ROOT_RESULTS${KRAKEN2_DIRECTORY}/${READ_FOLDER}/classified/$FASTQ2_R2 \
	 -output_fasta $ROOT_RESULTS$FASTQ_TO_FASTA$OUTPUT_FASTA
}


# Classification with blast.
function blast_classification {
    bash src/bash/classify_set_reads_blast.sh \
	 -path_seq $ROOT_RESULTS$FASTQ_TO_FASTA \
	 -path_db data/databases/blast/fda_argos_blast_database_27_08_2020/ \
	 -path_output $ROOT_RESULTS$BLAST_DIRECTORY \
	 -threads 8
}


# Find same taxonomics ID.
function find_same_taxonomics_id {
    python3 src/python/get_all_taxonomic_ids_same_genus_blast_kraken.py \
	    -path_blast results/30_08_2020_20h_56m_49s/blast_classification/1-MAR-LBA-ADN_S1_blast.txt \
	    -output results/30_08_2020_20h_56m_49s/same_taxonomics_id_kraken_blast/conserved.txt    
}


PROGRAM=pipeline.sh
VERSION=1.0

DESCRIPTION=$(cat << __DESCRIPTION__

__DESCRIPTION__
           )

OPTIONS=$(cat << __OPTIONS__

## OPTIONS ##
    -path_reads (Input)  The path with the reads.                                  *DIR: data/reads/GZIP_PAIRED_ADN/
__OPTIONS__
       )

# default options:
NAME_PROJECT=""

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
        *)       BAD_OPTION $1;;
    esac
done


#DATE=$(date +"%d_%m_%Y_%Hh_%Mm_%Ss")
DATE="16_09_2020_14h_50m_00s"
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

    # # Run the preprocess on all reads.
    PREPROCESS_FOLDER="trimmed_reads/"
    # run_preprocess_all_reads

    # Create Kraken 2 classification.
    KRAKEN2_DIRECTORY="kraken2_classification/"
    kraken2_classification


done
    

# # Get fastq R1 and R2 paired reads of Kraken 2 classification.
# READ_FOLDER=$(ls $ROOT_RESULTS${KRAKEN2_DIRECTORY})

# FASTQ1_R1=$(ls $ROOT_RESULTS${KRAKEN2_DIRECTORY}/${READ_FOLDER}/classified/ | grep "clseqs_1")

# # Ajouter un condition pour savoir si FASTQ2_R2 existe ?.
# FASTQ2_R2=$(echo ${FASTQ1_R1} | sed "s/clseqs_1/clseqs_2/" )

# OUTPUT_FASTA=$(echo ${FASTQ1_R1} | sed "s/clseqs_1/conversion/" )
# OUTPUT_FASTA=$(echo "${OUTPUT_FASTA%%.*}".fasta)

# # echo $FASTQ1_R1
# # echo $FASTQ2_R2
# # echo $OUTPUT_FASTA

# # echo $ROOT_RESULTS${KRAKEN2_DIRECTORY}/${READ_FOLDER}/classified/$FASTQ1_R1
# # ls $ROOT_RESULTS${KRAKEN2_DIRECTORY}/${READ_FOLDER}/classified/$FASTQ1_R1
# # echo $ROOT_RESULTS${KRAKEN2_DIRECTORY}/${READ_FOLDER}/classified/$FASTQ2_R2
# # ls $ROOT_RESULTS${KRAKEN2_DIRECTORY}/${READ_FOLDER}/classified/$FASTQ2_R2

# # Convert fastq to fasta.
# FASTQ_TO_FASTA="convert_fastq_to_fasta/"
# convert_fastq_to_fasta

# # Create blast classification.
# BLAST_DIRECTORY="blast_classification/"
# blast_classification

# # find same taxonomic ID from Kraken 2 and blast classifications.
# find_same_taxonomics_id

# bash src/bash/find_sequences_filtered_same_rank.sh \
#      -path_classified results/30_08_2020_20h_56m_49s/kraken2_classification/1-MAR-LBA-ADN_S1/classified/ \
#      -path_conserved results/30_08_2020_20h_56m_49s/same_taxonomics_id_kraken_blast/conserved.txt \
#      -path_output results/30_08_2020_20h_56m_49s/filtered_sequences/


# python3 src/python/create_depth_plots.py \
# 	-path_counter results/30_08_2020_20h_56m_49s/same_taxonomics_id_kraken_blast/countbis.txt \
# 	-path_conserved results/30_08_2020_20h_56m_49s/same_taxonomics_id_kraken_blast/conserved_sorted.txt \
# 	-path_plot results/30_08_2020_20h_56m_49s/all_plots/


# Test remove.
#test_remove
