#!/bin/bash
#$ -S /bin/bash
#$ -N build_fda_database
#$ -cwd
#$ -o out_3_fastq.out
#$ -e err_3_fastq.err
#$ -q short.q
#$ -l h_rt=48:00:00
#$ -pe thread 30
#$ -l h_vmem=2.5G
#$ -M your@mail.com

echo "JOB NAME: $JOB_NAME"
echo "JOB ID: $JOB_ID"
echo "QUEUE: $QUEUE"
echo "HOSTNAME: $HOSTNAME"
echo "SGE O WORKDIR: $SGE_O_WORKDIR"
echo "SGE TASK ID: $SGE_TASK_ID"
echo "NSLOTS: $NSLOTS"

# A shell script to classify reads from somes databases.

# Enable conda environment
conda active metagenomic_env

# Change fq extention to fastq.
fq_extention=$(ls SAMPLE_READS/*.fq 2> /dev/null | wc -l)
if [ "$fq_extention" != 0 ]
then
    echo "Change .fq extention to .fastq"
    for file in *.fq; do
        mv "$file" "$(basename "$file" ).fastq"
    done
else
    echo "All files are already in fastq format."
fi

# Maybe create Readme with information to understand who are cleaned.

# Classify sample reads for FDA-ARGOS database.
echo "Classify reads for FDA-ARGOS database."
bash ../bash/classify_set_sequences.sh \
     -path_reads ../../data/reads/PAIRED_SAMPLES_ADN \
     -path_db ../../data/databases/fda_argos_kraken_db_with_low_complexity\
     -path_output ../../results/reads_outputs/classify_fda_argos_with_low_complexity \
     -threads $THREAD 

# Classify reads for FDA + RefSeqHuman + Virus databases.
echo "Classify set of sequences for FDA database + RefSeqHuman + Virus"
bash classify_set_sequences.sh \
     -path_reads ../../data/reads/PAIRED_SAMPLES_ADN \
     -path_db database_fda_refseq_human_viral \
     -path_output ../../results/classify_fda_refseq_human_viral_with_low_complexity \
     -threads $THREAD
     
# Classify reads with RefSeq database.
echo "Classify set of sequences for RefSeq"
bash classify_set_sequences.sh \
     -path_reads ../../data/reads/PAIRED_SAMPLES_ADN \
     -path_db ../../data/databases/kraken \
     -path_output ../../results/classify_refseq_with_low_complexity \
     -threads $THREAD

# Classify reads with FDA-ARGOS database without low complexity sequences.
echo "Classify set of sequences for FDA Dust"
bash classify_set_sequences.sh \
     -path_reads ../../data/reads/PAIRED_SAMPLES_ADN \
     -path_db ../../data/DB_FDA_ARGOS_NO_LOW_COMPLEXITY \
     -path_output ../../results/classify_fda_without_low_complexity \
     -threads $THREAD

# Classify reads with preprocess FDA-ARGOS + RefSeqHuman + Virus db.
echo "Classify set of sequences for preprocess FDA database + RefSeqHuman + Virus"
bash classify_set_sequences.sh \
     -path_reads ../../data/reads/PAIRED_SAMPLES_ADN \
     -path_db ../../data/databases/database_fda_refseq_human_viral \
     -path_output ../../results/classify_FDA_refseq_human_viral_with_low_complexity \
     -threads $THREAD

# Disable conda environment
conda deactivate
