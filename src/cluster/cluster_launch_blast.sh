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

# Shell cluster script to launch blast analyse.
# e.g $qsub ../bash/launch_blast_analyse.sh -path_reads sample_reads \
# -path_db FDA_ARGOS_db -path_result blast_metaplan_output

# Enable conda environment
conda active metagenomic_env

# Run multiple blast analyses.
# FDA ARGOS Refseq Human Viral reads blast on FDA ARGOS blast database.
bash ../bash/launch_blast_analyse.sh \
     -path_reads ../../results/reads_outputs/output_reads_clean_FDA_refseq_human_viral \
     -path_db ../../data/raw_sequences/ALL_RAW_FILES_GENOMES_FDA_ARGOS-2020-02-04/MAKEBLAST_makeblast_database_fda_argos \
     -path_results ../../results/blasts/FDA_ARGOS_BLAST

# FDA ARGOS Refseq Human Viral reads blast on 16S RefSeq blast database.
bash  ../bash/launch_blast_analyse.sh \
      -path_reads ../../results/reads_outputs/output_reads_clean_FDA_refseq_human_viral \
      -path_db ../../data/databases/16S_DATABASE_REFSEQ/MAKEBLAST_16S \
      -path_results ../../results/blasts/16S_REFSEQ_BLAST

# run blast analyse.
bash ../bash/launch_blast_analyse.sh \
     -path_reads ../../data/reads/PAIRED_SAMPLES_ADN \
     -path_db ../../data/databases/database_fda_refseq_human_viral \
     -path_result ../../results/blast_metaplan_output

# Disable conda environment
conda deactivate
