#!/bin/bash
#$ -N BlastOnlyVir
#$ -cwd
#$ -o out16S.out
#$ -e err16S.err
#$ -q short.q
#$ -l h_rt=47:20:00
#$ -pe thread 10
#$ -l h_vmem=2.75G
#$ -M your@email.com

echo "JOB NAME: $JOB_NAME"
echo "JOB ID: $JOB_ID"
echo "QUEUE: $QUEUE"
echo "HOSTNAME: $HOSTNAME"
echo "SGE O WORKDIR: $SGE_O_WORKDIR"
echo "SGE TASK ID: $SGE_TASK_ID"
echo "NSLOTS: $NSLOTS"


# Just a bash script to create in cluster way a database from accesssion list on NCBI.
# qsub cluster_create_16S_database.sh {accession_list_file.seq} {output_name_fastq}
# e.g qsub cluster_create_16S_database.sh accession_list_16S_ncbi.seq 16S_output_database.fastq

# Activate conda environment.
conda activate metagenomic_env

# The path of accession list file.
ACCESSION_LIST_FILE=$1

# The name of output fastq.
NAME_OUTPUT_FASTQ=$2

# Check if the output fastq file already exists.
if [ -s $NAME_OUTPUT_FASTQ ] || [ -s ${NAME_OUTPUT_FASTQ}.fastq ]
then
    echo "The file $NAME_OUTPUT_FASTQ already exists."
else
    # Run the program to recover all sequence of database (16S) to one fastq.
    python ../python/get_database_from_accession_list.py -id $ACCESSION_LIST_FILE -o $NAME_OUTPUT_FASTQ
fi

# Deactivate conda.
conda deactivate metagenomic_env
