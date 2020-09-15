#!/bin/bash

# |-24_08_2020
#   |--trimmed_reads
#      |--info
#   |--kraken2_classification
#   |--blast_classification
#   |--convert_fastq_to_fasta
#   |--same_taxonomics_id_kraken_blast
#   |--report


# test remove.
function test_remove {
    rm -rf --verbose $RESULT_DIRECTORY
}


# Create results folder from specific date.
function create_pipeline_project {
    
    # Create a date when start pipeline.
    if [ -d "$RESULT_DIRECTORY" ]; then
	echo "$RESULT_DIRECTORY already exists."
    else
	mkdir -p --verbose $RESULT_DIRECTORY
    fi
}


# Trimmed reads.
function trimmed_read {
    bash src/bash/launch_reads_preprocess.sh \
	 -path_reads data/reads/GZIP_PAIRED_ADN/ \
	 -path_output $RESULT_DIRECTORY$TRIMMED_DIRECTORY \
	 -threads 8
}


# Classification with Kraken 2.
function kraken2_classification {
    bash src/bash/classify_set_reads_kraken.sh \
	 -path_reads $RESULT_DIRECTORY$TRIMMED_DIRECTORY \
	 -path_db data/databases/kraken_2/fda_argos_database_none_library_25_08_2020/ \
	 -path_output $RESULT_DIRECTORY$KRAKEN2_DIRECTORY \
	 -threads 8
}


# Convert fastq to fasta for blast algorithm.
function convert_fastq_to_fasta {
    bash src/bash/convert_fastq_to_fasta.sh \
	 -path_fastq_1 $RESULT_DIRECTORY${KRAKEN2_DIRECTORY}/${READ_FOLDER}/classified/$FASTQ1_R1 \
	 -path_fastq_2 $RESULT_DIRECTORY${KRAKEN2_DIRECTORY}/${READ_FOLDER}/classified/$FASTQ2_R2 \
	 -output_fasta $RESULT_DIRECTORY$FASTQ_TO_FASTA$OUTPUT_FASTA
}


# Classification with blast.
function blast_classification {
    bash src/bash/classify_set_reads_blast.sh \
	 -path_seq $RESULT_DIRECTORY$FASTQ_TO_FASTA \
	 -path_db data/databases/blast/fda_argos_blast_database_27_08_2020/ \
	 -path_output $RESULT_DIRECTORY$BLAST_DIRECTORY \
	 -threads 8
}


# Find same taxonomics ID.
function find_same_taxonomics_id {
    python3 src/python/get_all_taxonomic_ids_same_genus_blast_kraken.py \
	    -path_blast results/30_08_2020_20h_56m_49s/blast_classification/1-MAR-LBA-ADN_S1_blast.txt \
	    -output results/30_08_2020_20h_56m_49s/same_taxonomics_id_kraken_blast/conserved.txt    
}


#DATE=$(date +"%d_%m_%Y_%Hh_%Mm_%Ss")
DATE="30_08_2020_20h_56m_49s"
RESULT_DIRECTORY="results/${DATE}/"

# Create project folder.
#create_pipeline_project

# Trimmed read.
TRIMMED_DIRECTORY="trimmed_reads/"
trimmed_read

# # Create Kraken 2 classification.
# KRAKEN2_DIRECTORY="kraken2_classification/"
# #kraken2_classification

# # Get fastq R1 and R2 paired reads of Kraken 2 classification.
# READ_FOLDER=$(ls $RESULT_DIRECTORY${KRAKEN2_DIRECTORY})

# FASTQ1_R1=$(ls $RESULT_DIRECTORY${KRAKEN2_DIRECTORY}/${READ_FOLDER}/classified/ | grep "clseqs_1")

# # Ajouter un condition pour savoir si FASTQ2_R2 existe ?.
# FASTQ2_R2=$(echo ${FASTQ1_R1} | sed "s/clseqs_1/clseqs_2/" )

# OUTPUT_FASTA=$(echo ${FASTQ1_R1} | sed "s/clseqs_1/conversion/" )
# OUTPUT_FASTA=$(echo "${OUTPUT_FASTA%%.*}".fasta)

# # echo $FASTQ1_R1
# # echo $FASTQ2_R2
# # echo $OUTPUT_FASTA

# # echo $RESULT_DIRECTORY${KRAKEN2_DIRECTORY}/${READ_FOLDER}/classified/$FASTQ1_R1
# # ls $RESULT_DIRECTORY${KRAKEN2_DIRECTORY}/${READ_FOLDER}/classified/$FASTQ1_R1
# # echo $RESULT_DIRECTORY${KRAKEN2_DIRECTORY}/${READ_FOLDER}/classified/$FASTQ2_R2
# # ls $RESULT_DIRECTORY${KRAKEN2_DIRECTORY}/${READ_FOLDER}/classified/$FASTQ2_R2

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
