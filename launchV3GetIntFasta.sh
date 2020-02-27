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

# Folder with all .report.txt file from classification of reads.
folderInput=$1

# Data base ?
kingdomSearched=$2

# list of report.txt file.
report=$(ls $folderInput | grep -i .report.txt)

# Create 2 environnmentals variables for using next bash program like RecoverReads.sh .
export folderInput
export kingdomSearched

# For each .report.txt file we
for file in ${report}
do
    # Create folder for output result.
    mkdir -p ${folderInput}/${kingdomSearched}

    # I think he transforms $file.report.txt en $file.clsesq_x.fastq.
    clseqs1=$(echo $file | sed "s/report.txt/clseqs_1.fastq/")
    clseqs2=$(echo $file | sed "s/report.txt/clseqs_2.fastq/")

    #.
    outputFile=$(echo $file | sed "s/report.txt/interesting.fasta/")

    # Retrieve the taxonomic IDs of interest in the “report” file, then the reading names associated with these IDs in the “output” file in a temporary file (ReadsList.txt)
    ./GetIntFasta3.py ${folderInput} $file ${kingdomSearched}

    # recover reads.
    ./RecoverReads.sh ${folderInput}/${kingdomSearched}/${file}ReadsList.txt ${folderInput}/${clseqs1} ${folderInput}/${clseqs2} ${folderInput}/${kingdomSearched}/${outputFile}

    # Clean the output file of previously python program.
    rm ${folderInput}/${kingdomSearched}/${file}ReadsList.txt
done

# Deactivate conda environnment.
source deactivate
