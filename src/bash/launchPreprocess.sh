#!/bin/bash
#$ -N PreprocessKraken
#$ -cwd
#$ -o outPp.out
#$ -e errPp.err
#$ -q short.q
#$ -l h_rt=47:20:00
#$ -pe thread 10
#$ -l h_vmem=11G
#$ -M your@email.com

echo "JOB NAME: $JOB_NAME"
echo "JOB ID: $JOB_ID"
echo "QUEUE: $QUEUE"
echo "HOSTNAME: $HOSTNAME"
echo "SGE O WORKDIR: $SGE_O_WORKDIR"
echo "SGE TASK ID: $SGE_TASK_ID"
echo "NSLOTS: $NSLOTS"

# Example : qsub launchPreprocess.sh {folder}

# Activate a specific environnment with BBMAP program (clumpishy.sh) and Trimmomatic.
source activate EnvAntL

# the path of folder where sequence are (reads).
FOLDER_INPUT=$1

# Move to the folder of sequence.
cd ${FOLDER_INPUT}

# Check if the reads files from database are already decompressed.
reads_unzip=$(ls $DBNAME/taxonomy/*.gz 2> /dev/null | wc -l)
if [ "$reads_unzip" != "0" ]
then
    echo "Reads files are not unzipped."
    # list all R1*fasta.gz files same like ls *R1.fasta.gz
    R1fastQgz=$(ls | grep -i R1.*\.fastq)
else
    echo "Reads files are already zipped."
    # list all R1*fasta.gz files same like ls *R1.fasta.gz
    R1fastQgz=$(ls | grep -i R1.*\.fastq\.gz)
fi

# list all R1*fasta.gz files same like ls *R1.fasta.gz
#R1fastQgz=$(ls | grep -i R1.*\.fastq\.gz)

# Important of zipped file in parameters ?

# Main loop
for R1fastQgzFile in ${R1fastQgz}; # For all R1 file in the folder.
do
    # Create a R2 file when the file is paired and replace R1 by R2.
    R2fastQgzFile=$(echo ${R1fastQgzFile} | sed 's/R1/R2/')

    # For R1 file they add R1_dedupe and R2_dedupe.
    dedupe1=$(echo ${R1fastQgzFile} | sed 's/R1/R1_dedupe/')
    dedupe2=$(echo ${R1fastQgzFile} | sed 's/R1/R2_dedupe/')

    # Paired reads.
    if [ -f "${R2fastQgzFile}" ];
    then
        # Count reads
        countReads=$(zcat ${R1fastQgzFile} | grep '^+$' | wc -l )

        # Multiply by 2 le number of R1 reads and create a info txt.
        echo $(($countReads * 2)) > ${R1fastQgzFile%%.*}.info.txt
        echo "PairedEnd Sample"

        # In BBTools : BMap is a splice-aware global aligner for DNA and RNA sequencing reads.
        clumpify.sh qin=33 in1=${R1fastQgzFile} in2=${R2fastQgzFile} out1=${dedupe1} out2=${dedupe2} dedupe

        echo "Deduplicated"
        # Using Trimmonatic a java program to deduplicate the replicat in paired reads.
        trimmomatic PE -threads 10 ${dedupe1} ${dedupe2} ${R1fastQgzFile%%.*}_paired.fq.gz ${R1fastQgzFile%%.*}_unpaired.fq.gz ${R2fastQgzFile%%.*}_paired.fq.gz ${R2fastQgzFile%%.*}_unpaired.fq.gz AVGQUAL:20 MINLEN:50

        # After we trimmed with removing of dedupe 1 and 2.
        echo "Trimmed"
        rm ${dedupe1} ${dedupe2}
    else
        # Count R1 read.
        zcat ${R1fastQgzFile} | grep '^+$' | wc -l > ${R1fastQgzFile%%.*}.info.txt

        echo "SingleEnd Sample"
        # In BBMAP??
        clumpify.sh qin=33 in=${R1fastQgzFile} out=${dedupe1} dedupe

        echo "Deduplicated"
        # Using deduplicate replicat into the reads.
        trimmomatic SE -threads 10 ${dedupe1} ${R1fastQgzFile%%.*}_trimmed.fq.gz AVGQUAL:20 MINLEN:50

        # After we trimmed with removing dedupe 1.
        echo "Trimmed"
        rm ${dedupe1}
    fi
done
source deactivate
