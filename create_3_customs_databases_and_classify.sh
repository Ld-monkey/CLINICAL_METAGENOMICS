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

# Call bash script to run kraken 2 on FDA ARGOS data base.
module load kraken

# Temporarily adding a path of dustmasker or segmasker in PATH variable to mask low-complexity region.
PATH=$PATH:/data2/apps/blastplus/2.2.31/bin

# Build FDA database
#echo "Build FDA database"
#bash FDA_database_kraken2.sh -ref FDA_ARGOS_all_ncbi_genomes-2020-02-04 -database database_clean -threads 30

# Classify set of sequences (reads)
#echo "Classify set of sequences"
#bash classify_set_sequences.sh /data1/scratch/masalm/Valid_Mg_Groute/190710-Nextseq-bact/FASTQ database_clean 30 output_reads_clean_FDA

# Build FDA database + RefSeqHuman + Virus
#echo "Build FDA database + RefSeqHuman + Virus"
#bash FDA_RefSeq_Human_Viral.sh -ref ALL_RAW_FILES_GENOMES_FDA_ARGOS-2020-02-04 -database database_fda_refseq_human_viral -threads 30

# Classify set of sequences (reads).
#echo "Classify set of sequences for FDA database + RefSeqHuman + Virus"
#bash classify_set_sequences.sh /data1/scratch/masalm/Valid_Mg_Groute/190710-Nextseq-bact/FASTQ database_fda_refseq_human_viral 30 output_reads_clean_FDA_refseq_human_viral


# Preprocess on reads.
#bash lauchPreprocess.sh {folder_reads_preprocess}

# Change fq extention to fastq.
fq_extention=$(ls /data1/scratch/masalm/LUDOVIC/METAGENOMICS/PAIRED_SAMPLES_ADN/*.fq 2> /dev/null | wc -l)
if [ "$fq_extention" != 0 ]
then
    echo "Change .fq extention to .fastq"
    for file in *.fq; do
        mv "$file" "$(basename "$file" ).fastq"
    done
else
    echo "All files are already in fastq format."
fi


# Classify RefSeq set of sequences (reads).
echo "Classify set of sequences for RefSeq"
bash classify_set_sequences.sh /data1/scratch/masalm/LUDOVIC/METAGENOMICS/PAIRED_SAMPLES_ADN /data2/fdb/kraken 30 output_prepocess_reads_RefSeq

# Classify set of sequences (reads) of prepocess FDA dust
echo "Classify set of sequences for FDA Dust"
bash classify_set_sequences.sh /data1/scratch/masalm/LUDOVIC/METAGENOMICS/PAIRED_SAMPLES_ADN DB_FDA_ARGOS_NO_LOW_COMPLEXITY 30 output_prepocess_reads_clean_FDA

#  Classify set of sequences (reads) on preprocess on FDA database + RefSeqHuman + Virus
echo "Classify set of sequences for preprocess FDA database + RefSeqHuman + Virus"
bash classify_set_sequences.sh /data1/scratch/masalm/LUDOVIC/METAGENOMICS/PAIRED_SAMPLES_ADN database_fda_refseq_human_viral 30 output_preprocess_reads_clean_FDA_refseq_human_viral

# Purge module
module unload kraken
