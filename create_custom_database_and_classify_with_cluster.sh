#!/bin/bash

#$ -S /bin/bash
#$ -N build_fda_database
#$ -cwd
#$ -o out2_clean.out
#$ -e err2_clean.err
#$ -q short.q
#$ -l h_rt=48:00:00
#$ -pe thread 30
#$ -l h_vmem=2.5G
#$ -M your@mail.com

echo "JOB NAME: $JOB_NAME"
echo "JOB ID: $JOB_ID"
echo "QUEUE: $QUEUE"
echo "HOSTNAME: $HOSTNAME"
echo "SGE O WORKDIR: $SGE_O_WORKDIR"
echo "SGE TASK ID: $SGE_TASK_ID"
echo "NSLOTS: $NSLOTS"

# Call bash script to run kraken 2 on FDA ARGOS data base.
module load kraken

# Temporarily adding a path of dustmasker or segmasker in PATH variable to mask low-complexity region.
PATH=$PATH:/data2/apps/blastplus/2.2.31/bin

# Build FDA database
echo "Build FDA database"
bash FDA_database_kraken2.sh -ref FDA_ARGOS_all_ncbi_genomes-2020-02-04 -database database_clean -threads 30

# Classify set of sequences (reads)
echo "Classify set of sequences"
bash classify_set_sequences.sh /data1/scratch/masalm/Valid_Mg_Groute/190710-Nextseq-bact/FASTQ database_clean 30 output_reads_clean_FDA

# Purge module
module unload kraken
