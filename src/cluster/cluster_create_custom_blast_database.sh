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

# Activate conda environment.
source activate EnvAntL

# Load in conda the module.
module load blastplus/2.2.31

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

# Deactivate conda.
source deactivate
