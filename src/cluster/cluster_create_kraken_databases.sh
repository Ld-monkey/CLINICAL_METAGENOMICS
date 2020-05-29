#!/bin/bash
#$ -S /bin/bash
#$ -N build_kraken_2_db
#$ -cwd
#$ -o out_build_kraken_db.out
#$ -e err_build_kraken_db.err
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

# A shell script to create kraken 2 databases :
# * FDA-ARGOS database
# * FDA-ARGOS + RefSeqHuman + Virus database
# * RefSeq already exists.
# * Mycocosm fungi CDS

# It's not necessary to re-download the kraken taxonomy for each database.

# Enable conda environment
conda activate metagenomic_env

# Thread variable.
THREAD=6

# # Build FDA-ARGOS database with low complexity sequences.
# echo "Build FDA-ARGOS kraken database"
# bash ../bash/create_kraken_database.sh \
#      -path_seq ../../data/raw_sequences/ALL_RAW_FILES_GENOMES_FDA_ARGOS-2020-02-04 \
#      -path_db ../../data/databases/fda_argos_kraken_db_with_low_complexity \
#      -type_db viral \
#      -threads $THREAD

# # Build FDA-ARGOS + RefSeqHuman + Virus in one database.
# echo "Build FDA database + RefSeqHuman + Virus kraken database"
# bash  ../bash/create_kraken_database.sh \
#       -path_seq \
#       -path_db ../../data/databases/database_fda_refseq_human_viral \
#       -type_db viral \
#       -threads $thread

# build kraken database with mycocosm (fungi) coding sequences (cds)
# echo "Build mycocosm (fungi) kraken database."
# bash  ../bash/create_kraken_database.sh \
#       -path_seq ../../data/raw_sequences/mycocosm_fungi_CDS_19_05_2020 \
#       -path_db ../../data/databases/mycocosm_fungi_CDS_kraken_database_19_05_2020 \
#       -type_db fungi \
#       -threads $THREAD
# echo "Kraken 2 - Mycocosm (fungi) database done !"

# echo "Build add mycocosm (fungi) kraken database."
# bash  ../bash/create_kraken_database.sh \
#       -path_seq ../../data/raw_sequences/mycocosm_ncbi_add_20_05_2020 \
#       -path_db ../../data/databases/mycocosm_fungi_CDS_kraken_database_19_05_2020 \
#       -type_db fungi \
#       -threads $THREAD
# echo "Kraken 2 - Mycocosm (fungi) database done !"

echo "Build no add mycocosm (fungi) kraken database."
bash  ../bash/create_kraken_database.sh \
      -path_seq ../../data/raw_sequences/mycocosm_fungi_ncbi_CDS_28_05_2020/fungi \
      -path_db ../../data/databases/mycocosm_fungi_CDS_kraken_database_28_05_2020 \
      -type_db fungi \
      -threads $THREAD
echo "Kraken 2 - Mycocosm (fungi) database done !"

# Disable conda environment
conda deactivate
