#!/bin/bash
#$ -S /bin/bash
#$ -N GetIntFasta
#$ -cwd
#$ -o outGetIntFasta.out
#$ -e errGetIntFasta.err
#$ -q short.q
#$ -l h_rt=47:20:00
#$ -pe thread 1
#$ -l h_vmem=20G
#$ -M your@email.com

echo "JOB NAME: $JOB_NAME"
echo "JOB ID: $JOB_ID"
echo "QUEUE: $QUEUE"
echo "HOSTNAME: $HOSTNAME"
echo "SGE O WORKDIR: $SGE_O_WORKDIR"
echo "SGE TASK ID: $SGE_TASK_ID"
echo "NSLOTS: $NSLOTS"

#e.g : $qsub launchV3GetIntFasta.sh {folder} {Bacteria/Viruses}

# Activate conda environnment.
source activate EnvAntL

# The path folder with all .report.txt file from classification of reads.
PATH_INPUT_FOLDER=$1

# The taxon selectionned. Only 3 possibilities Viruses or Bacteria or Fungi.
TAXON=$2

# List of report.txt file.
REPORT_FILES=$(ls $PATH_INPUT_FOLDER | grep -i .report.txt)

# Create 2 environnmentals variables for using next bash program like
# RecoverReads.sh .
export PATH_INPUT_FOLDER
export TAXON

# For each .report.txt file we find the taxonomic ID and the corresponding
# sequences.
for file in ${REPORT_FILES}
do
    # Create folder for output result e.g PATH_INPUT_FOLDER/Bacteria .
    mkdir -p ${PATH_INPUT_FOLDER}/${TAXON}

    # Trick to transforms *.report.txt name in *.clsesq_*.fastq.
    clseqs1=$(echo $file | sed "s/report.txt/clseqs_1.fastq/")
    clseqs2=$(echo $file | sed "s/report.txt/clseqs_2.fastq/")

    # Trick to transforms *.report.txt name in *.interesting.fasta.
    output_interest_fasta=$(echo $file | sed "s/report.txt/interesting.fasta/")

    # Retrieve taxonomic IDs of interest in the “report” file, then
    # write names associated with these IDs in the “output” file in a
    # temporary file (ReadsList.txt).
    ./GetIntFasta3.py ${PATH_INPUT_FOLDER} $file ${TAXON}

    # Gets reads in "clseqs" files from names, and transforms them into fasta
    # format.
    ./RecoverReads.sh ${PATH_INPUT_FOLDER}/${TAXON}/${file}ReadsList.txt ${PATH_INPUT_FOLDER}/${clseqs1} ${PATH_INPUT_FOLDER}/${clseqs2} ${PATH_INPUT_FOLDER}/${TAXON}/${output_interest_fasta}

    # Clean the output *ReadsList.txt of previously python program.
    rm ${PATH_INPUT_FOLDER}/${TAXON}/${file}ReadsList.txt
done

# Deactivate conda environnment.
source deactivate
