#!/bin/bash
#$ -N BlastOnlyVir
#$ -cwd
#$ -o outBlast.out
#$ -e errBlast.err
#$ -q short.q
#$ -l h_rt=47:20:00
#$ -pe thread 40
#$ -l h_vmem=2.75G
#$ -M your@email.com

echo "JOB NAME: $JOB_NAME"
echo "JOB ID: $JOB_ID"
echo "QUEUE: $QUEUE"
echo "HOSTNAME: $HOSTNAME"
echo "SGE O WORKDIR: $SGE_O_WORKDIR"
echo "SGE TASK ID: $SGE_TASK_ID"
echo "NSLOTS: $NSLOTS"

# Enable conda environment
conda activate metagenomic_env

DATE=$(date +%d_%m_%Y)
PATH_DATABASE=../../data/databases/
NAME_VIRAL_FOLDER=blast_viral_db_${DATE}_with_low_complexity
NAME_BACTERIA_FOLDER=blast_bacteria_db_${DATE}_with_low_complexity

# Create folder for viral and bacteria blast databases.
mkdir -p $PATH_DATABASE$NAME_VIRAL_FOLDER
mkdir -p $PATH_DATABASE$NAME_BACTERIA_FOLDER

# Create viral blast database from Refseq viral sequences without remove low complexity (with low complexity).
makeblastdb -in ../../data/raw_sequences/viral_sequences_from_refseq_28_04_2020/all_genomic_viral_sequences.fasta \
            -parse_seqids \
            -dbtype nucl \
            -title BlastViralDatabase \
            -taxid_map ../../data/raw_sequences/viral_sequences_from_refseq_28_04_2020/viral_map.complete \
            -out $PATH_DATABASE$NAME_VIRAL_FOLDER/$NAME_VIRAL_FOLDER

echo "$NAME_VIRAL_FOLDER is created"

# Create bacteria blast database from Refseq bacterial sequences without remove low complexity (with low complexity).
makeblastdb -in ../../data/raw_sequences/bacteria_sequences_from_refseq_01_05_2020/all_genomic_bacteria_sequences.fasta \
            -parse_seqids \
            -dbtype nucl \
            -title BlastBacteriaDatabase \
            -taxid_map ../../data/raw_sequences/bacteria_sequences_from_refseq_01_05_2020/bacteria_map.complete \
            -out $PATH_DATABASE$NAME_BACTERIA_FOLDER/$NAME_BACTERIA_FOLDER

echo "$NAME_BACTERIA_FOLDER is created"

# Disable conda environment
conda deactivate
