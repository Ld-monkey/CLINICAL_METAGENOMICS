#!/bin/bash
#$ -N PreprocessKraken
#$ -cwd
#$ -o outPp.out
#$ -e errPp.err
#$ -q short.q
#$ -l h_rt=47:20:00
#$ -pe thread 10
#$ -l h_vmem=11G
#$ -M your@email.com

echo "JOB NAME: $JOB_NAME"
echo "JOB ID: $JOB_ID"
echo "QUEUE: $QUEUE"
echo "HOSTNAME: $HOSTNAME"
echo "SGE O WORKDIR: $SGE_O_WORKDIR"
echo "SGE TASK ID: $SGE_TASK_ID"
echo "NSLOTS: $NSLOTS"

# Shell cluster script to launch preprocess on sequences or reads.
# This action removes poor quality and duplicates reads.
# In other words, for each sample (single end or paired end) + deduplication
# and qualitative sorting.
# e.g $qsub cluster_launch_preprocess.sh -path_reads {folder_with_reads}

# Enable conda environment
conda active metagenomic_env

# Run script.
bash ../bash/launch_preprocess.sh -path_reads all_reads_from_sample

# Disable conda environment
conda deactivate
