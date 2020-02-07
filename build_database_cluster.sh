#!/bin/bash

#$ -S /bin/bash
#$ -N build_fda_database
#$ -cwd
#$ -o out2.out
#$ -e err2.err
#$ -q short.q
#$ -l h_rt=48:00:00
#$ -pe thread 30
#$ -l h_vmem=2.5G
#$ -M machin@gmail.com

echo "JOB NAME: $JOB_NAME"
echo "JOB ID: $JOB_ID"
echo "QUEUE: $QUEUE"
echo "HOSTNAME: $HOSTNAME"
echo "SGE O WORKDIR: $SGE_O_WORKDIR"
echo "SGE TASK ID: $SGE_TASK_ID"
echo "NSLOTS: $NSLOTS"

# Call bash script to run kraken 2 on FDA ARGOS data base.
module load kraken
bash FDA_database_kraken2.sh -ref FDA_ARGOS_all_ncbi_genomes-2020-02-04 -database database -threads 30
module unload kraken
