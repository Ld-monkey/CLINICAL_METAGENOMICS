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

# Activate conda environment.
source activate EnvAntL

# Load the module in the cluster. 
module load blastplus/2.2.31

# run blast analyse.
bash ../bash/launch_blast_analyse.sh \
     -path_reads ../../data/reads/PAIRED_SAMPLES_ADN \
     -path_db ../../data/databases/database_fda_refseq_human_viral \
     -path_result ../../results/blast_metaplan_output

# Deactivate conda.
source deactivate
