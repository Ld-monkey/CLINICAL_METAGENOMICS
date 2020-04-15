#!/bin/bash
#$ -N BlastOnlyVir
#$ -cwd
#$ -o outdatabaseblast.out
#$ -e errdatabaseblast.err
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

# The cluster file to activate database creation for blast.
# Without low complexity in final database.

# e.g qsub ../bash/create_blast_database_without_low_complexity.sh \
#    -path_seqs test_database_blast/ \
#    -output_fasta output_multi_fasta \
#    -name_db database_test

# Activate module.
module load blastplus/2.2.31

# Deactivate module.
module unload blastplus/2.2.31
