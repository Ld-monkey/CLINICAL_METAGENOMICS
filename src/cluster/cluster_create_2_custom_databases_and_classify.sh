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

# A shell script to create 2 databases :
# * FDA-ARGOS database
# * FDA-ARGOS + RefSeqHuman + Virus database
# * RefSeq already exists.
# And classified reads from somes databases.

# Enable conda environment
conda active metagenomic_env

# Variable of path of sample paired reads
SAMPLE_READS=../../data/reads/PAIRED_SAMPLES_ADN

# Build FDA-ARGOS database.
echo "Build FDA-ARGOS database"
bash ../bash/create_kraken_database.sh \
     -ref ../../data/raw_sequences/ALL_RAW_FILES_GENOMES_FDA_ARGOS-2020-02-04 \
     -database ../../data/databases/fda_argos_kraken_db_with_low_complexity \
     -threads 5

# Build FDA-ARGOS + RefSeqHuman + Virus in one database.
echo "Build FDA database + RefSeqHuman + Virus database"
bash  ../bash/create_kraken_database.sh \
      -ref ALL_RAW_FILES_GENOMES_FDA_ARGOS-2020-02-04 \
      -database database_fda_refseq_human_viral \
      -threads 30

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

# Classify reads for FDA-ARGOS database.
echo "Classify reads for FDA-ARGOS database."
bash classify_set_sequences.sh \
     /data1/scratch/masalm/Valid_Mg_Groute/190710-Nextseq-bact/FASTQ \
     database_clean \
     30 \
     output_reads_clean_FDA

# Classify reads for FDA database + RefSeqHuman + Virus.
echo "Classify set of sequences for FDA database + RefSeqHuman + Virus"
bash classify_set_sequences.sh \
     /data1/scratch/masalm/Valid_Mg_Groute/190710-Nextseq-bact/FASTQ \
     database_fda_refseq_human_viral \
     30 \
     output_reads_clean_FDA_refseq_human_viral

# Classify reads with RefSeq db.
echo "Classify set of sequences for RefSeq"
bash classify_set_sequences.sh \
     /data1/scratch/masalm/LUDOVIC/METAGENOMICS/PAIRED_SAMPLES_ADN \
     /data2/fdb/kraken \
     30 \
     output_prepocess_reads_RefSeq

# Classify reads with prepocess + dust FDA-ARGOS db.
echo "Classify set of sequences for FDA Dust"
bash classify_set_sequences.sh \
     /data1/scratch/masalm/LUDOVIC/METAGENOMICS/PAIRED_SAMPLES_ADN \
     DB_FDA_ARGOS_NO_LOW_COMPLEXITY \
     30 \
     output_prepocess_reads_clean_FDA

# Classify reads with preprocess FDA-ARGOS + RefSeqHuman + Virus db.
echo "Classify set of sequences for preprocess FDA database + RefSeqHuman + Virus"
bash classify_set_sequences.sh \
     /data1/scratch/masalm/LUDOVIC/METAGENOMICS/PAIRED_SAMPLES_ADN \
     database_fda_refseq_human_viral \
     30 \
     output_preprocess_reads_clean_FDA_refseq_human_viral

# Purge kraken 2 module.
module unload kraken
