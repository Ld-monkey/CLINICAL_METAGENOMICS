#!/bin/bash
#$ -S /bin/bash
#$ -N build_fda_database
#$ -cwd
#$ -o out_3_fastq.out
#$ -e err_3_fastq.err
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

# A shell script to create 2 databases :
# * FDA-ARGOS database
# * FDA-ARGOS + RefSeqHuman + Virus database
# * RefSeq already exists.

# Enable conda environment
conda active metagenomic_env

# Thread variable.
THREAD=7

# Variable of path of sample paired reads
SAMPLE_READS=../../data/reads/PAIRED_SAMPLES_ADN

# Build FDA-ARGOS database with low complexity sequences.
echo "Build FDA-ARGOS database"
bash ../bash/create_kraken_database.sh \
     -ref ../../data/raw_sequences/ALL_RAW_FILES_GENOMES_FDA_ARGOS-2020-02-04 \
     -database ../../data/databases/fda_argos_kraken_db_with_low_complexity \
     -threads $THREAD

# Build FDA-ARGOS + RefSeqHuman + Virus in one database.
echo "Build FDA database + RefSeqHuman + Virus database"
bash  ../bash/create_kraken_database.sh \
      -ref  \
      -database database_fda_refseq_human_viral \
      -threads $THREAD

# Disable conda environment
conda deactivate
