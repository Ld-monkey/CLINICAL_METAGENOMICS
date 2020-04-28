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
conda active metagenomic_env

# Create viral blast database from Refseq viral sequences.
makeblastdb -in ../../data/raw_sequences/viral_sequences_from_refseq/all_genomic_viral_sequences.fasta \
            -parse_seqids \
            -dbtype nucl \
            -title BlastViralDatabase \
            -taxid_map ../../data/raw_sequences/viral_sequences_from_refseq/viral_map.complete

# Create bacteria blast database from Refseq bacterial sequences.
makeblastdb -in ../../data/raw_sequences/bacteria_sequences_from_refseq/all_genomic_viral_sequences.fasta \
            -parse_seqids \
            -dbtype nucl \
            -title BlastBacteriaDatabase \
            -taxid_map ../../data/raw_sequences/bacteria_sequences_from_refseq/bacteria_map.complete

# Disable conda environment
conda deactivate
