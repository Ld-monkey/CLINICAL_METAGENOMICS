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

# qsub create_blast_database.sh
# e.g qsub create_blast_database.sh test_database_blast/ output_multi_fasta database_test

# Path of all raw fasta files.
PATH_RAW_FASTA_FILE=$1

# Name of the output multi-fasta file.
BASENAME_OUTPUT_MULTI_FASTA=$2

# Name of the database output. (i don't know if is necessary)
NAME_DATABASE=$3

# Activate module in the cluster.
module load blastplus/2.2.31

# Check if the multiple fasta file is already created.
if [ -s $PATH_RAW_FASTA_FILE$BASENAME_OUTPUT_MULTI_FASTA.fa ]
then
    echo "The file $PATH_RAW_FASTA_FILE$BASENAME_OUTPUT_MULTI_FASTA.fa already exist."
else
    # Create a unique multi fasta file with .fsa extention
    for fasta_file in $PATH_RAW_FASTA_FILE*.fna
    do
        echo "$fasta_file is added"
        cat $fasta_file >> $PATH_RAW_FASTA_FILE$BASENAME_OUTPUT_MULTI_FASTA.fa
    done
fi

# Check if the folder DUSTMASKER_$NAME_DATABASE exists.
if [ -d ${PATH_RAW_FASTA_FILE}DUSTMASKER_$NAME_DATABASE ]
then
    echo "The folder DUSTMASKER_$NAME_DATABASE already exists."
else
    echo "Create DUSTMASKER_$NAME_DATABASE."
    mkdir ${PATH_RAW_FASTA_FILE}DUSTMASKER_$NAME_DATABASE
    echo "Create DUSTMASKER_$NAME_DATABASE done."
fi

# Check if in the folder dustmasker there is dustmasker.asnb.
if [ -s ${PATH_RAW_FASTA_FILE}DUSTMASKER_$NAME_DATABASE/dustmasker.asnb ]
then
    echo "The dustmasker file already exists for the database."
else
    echo "Remove low complexity."
    # Remove low complexity with dustmasker only for nucleotide.
    dustmasker -in $PATH_RAW_FASTA_FILE$BASENAME_OUTPUT_MULTI_FASTA.fa \
               -infmt fasta -parse_seqids -outfmt maskinfo_asn1_bin \
               -out ${PATH_RAW_FASTA_FILE}DUSTMASKER_$NAME_DATABASE/dustmasker.asnb
    echo "Low complexity done."
fi

# Check if the database already exists.
if [ -d ${PATH_RAW_FASTA_FILE}MAKEBLAST_$NAME_DATABASE ]
then
    echo "The folder MAKEBLAST_$NAME_DATABASE already exists."
    echo "In this case, the database : $NAME_DATABASE already exists"
else
    echo "Create the folder MAKEBLAST_$NAME_DATABASE"
    mkdir ${PATH_RAW_FASTA_FILE}MAKEBLAST_$NAME_DATABASE
    echo "Folder done"

    # Create a simple custom database from a multi-fasta file.
    echo "Create database."
    echo "$PATH_RAW_FASTA_FILE$BASENAME_OUTPUT_MULTI_FASTA.fa"

    # Create database with makeblastdb.
    makeblastdb -in $PATH_RAW_FASTA_FILE$BASENAME_OUTPUT_MULTI_FASTA.fa \
                -dbtype nucl \
                -parse_seqids \
                -mask_data ${PATH_RAW_FASTA_FILE}DUSTMASKER_$NAME_DATABASE/dustmasker.asnb \
                -out $PATH_RAW_FASTA_FILE$NAME_DATABASE \
                -title "Database with makeblastdb"
    echo "Database done."

    # Move all files of the database in the folder.
    mv $PATH_RAW_FASTA_FILE$NAME_DATABASE.n* ${PATH_RAW_FASTA_FILE}MAKEBLAST_$NAME_DATABASE/

    echo "All file are moved in ${PATH_RAW_FASTA_FILE}MAKEBLAST_$NAME_DATABASE"
fi

# Print a summary of the target database in README.txt .
blastdbcmd -db ${PATH_RAW_FASTA_FILE}MAKEBLAST_$NAME_DATABASE/$NAME_DATABASE -info \
           > ${PATH_RAW_FASTA_FILE}MAKEBLAST_$NAME_DATABASE/README.txt

# Deactivate module.
module unload blastplus/2.2.31
