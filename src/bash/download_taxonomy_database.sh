#!/bin/bash

#$ -S /bin/bash
#$ -N download_taxonomy_database
#$ -cwd
#$ -o out_taxonomy.out
#$ -e err_taxonomy.err
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

echo "wget test"
wget -h
wget --version
echo "test wget done"

# Build FDA database + RefSeqHuman + Virus
echo "Build taxonomy FDA database + RefSeqHuman + Virus"

echo "Installing NCBI taxonomy in database"
kraken2-build --download-taxonomy --db database_fda_refseq_human_viral --use-ftp
echo "Unzip all data"
gunzip $database_fda_refseq_human_viral/taxonmy/*.gz
echo "Unzip done !"

# Purge module
module unload kraken
