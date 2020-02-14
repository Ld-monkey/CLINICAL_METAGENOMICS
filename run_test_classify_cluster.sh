#!/bin/bash

#$ -S /bin/bash
#$ -N run_classify_test
#$ -cwd
#$ -o out2_classify_refseq.out
#$ -e err2_classify_refseq.err
#$ -q short.q
#$ -l h_rt=47:20:00
#$ -pe thread 3
#$ -l h_vmem=36.5G
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

# Classify set of sequences (reads) with a FDA database.
#bash classify_set_sequences.sh /data1/scratch/masalm/Valid_Mg_Groute/190710-Nextseq-bact/FASTQ database 3 output_reads_FDA_ARGOS

# Next classify set of sequences (reads) with a RefSeq database
bash classify_set_sequences.sh /data1/scratch/masalm/Valid_Mg_Groute/190710-Nextseq-bact/FASTQ /data2/fdb/kraken 3 output_reads_RefSeq

# Purge module
module unload kraken
