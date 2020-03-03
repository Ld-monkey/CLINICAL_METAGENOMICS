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

#qsub launchBlast.sh {folder}

# Activate conda environment.
source activate EnvAntL

# Load in conda the module.
module load blastplus/2.2.31

# Path of the RefSeq database.
DATA_BASE_REFSEQ=/data2/home/masalm/Antoine/DB/RefSeq_viral/refseq_viral_genomic

# Path to the MetaPhlan database.
DATA_BASE_METAPHLAN=/data2/home/masalm/Antoine/DB/MetaPhlAn/mpa_v20_m200_bis.fna

# Folder containing samples.
folderInput=$1

# Move in the folder/Viruses.
cd ${folderInput}/Viruses

# Get all interesting files *.interesting.fasta .
interesting=$(ls | grep -i interesting)

if [ -d Viruses ]
then
    echo "folder exists."
else
    echo "Folder Viruses doesn't exists."
fi


# For each sample align sequence on database.
for interestingFile in ${interesting};
do
    # Display file ? and in parallel <
    # --block size is size of block in bytes to read at a time.
    # --recstart is given this will be used to split at record start.
    # --pipe maxes out at around 1 GB/s input, and 100 MB/s output .

    # For blast + (http://nebc.nerc.ac.uk/bioinformatics/documentation/blast+/user_manual.pdf)
    # blastn -task megablast : used to find very similar sequences.
    # -evalue : Expectation value threshold for saving hits.
    # -db : File name of BLAST database.
    # -outfmt : Allows for the specification of the search application’s output format.
    # -max_target_seqs : Maximum number of aligned sequences to keep from the BLASTdatabase.
    # > output = ${interestingFile%%.*}.blasttemp.txt
    cat $interestingFile | parallel --block 1M --recstart '>' --pipe blastn -task megablast -evalue 10e-10 -db $DATA_BASE_REFSEQ -num_threads 1 -outfmt \"7 qseqid sseqid sstart send evalue bitscore slen staxids\" -max_target_seqs 1 -max_hsps 1 > ${interestingFile%%.*}.blasttemp.txt

    # Replace all "processed" in d.
    sed "/\processed\b/d" ${interestingFile%%.*}.blasttemp.txt > ${interestingFile%%.*}.blasttemp2.txt

    # tac : concatenate and write files in reverse ?
    tac ${interestingFile%%.*}.blasttemp2.txt | sed '/0 hits/I,+3 d' |tac > ${interestingFile%%.*}.blast.txt

    # Check if *interestinfFile.fasta.blast.txt exists.
    if [ -s "${interestingFile%%.*}.blast.txt" ]
    then
        # Remove blast temporary files.
        rm ${interestingFile%%.*}.blasttemp.txt ${interestingFile%%.*}.blasttemp2.txt
    else
        echo "${interestingFile%%.*}.blast.txt not generated. Available storage space could be the reason !"
    fi
done

# Move in the Bacteria folder.
cd ../Bacteria

# Get all interesting files *.interesting.fasta .
interesting=$(ls | grep -i interesting)

# For each sample align sequence on database.
for interestingFile in ${interesting};
do
    # Run the blast program.
    cat $interestingFile | parallel --block 50M --recstart '>' --pipe blastn -task megablast -evalue 10e-10 -db $DATA_BASE_METAPHLAN -num_threads 1 -outfmt \"7 qseqid sseqid sstart send evalue bitscore slen staxids\" -max_target_seqs 1 -max_hsps 1 > ${interestingFile%%.*}.blasttemp.txt    sed "/\processed\b/d" ${interestingFile%%.*}.blasttemp.txt > ${interestingFile%%.*}.blasttemp2.txt

    # Concatenate and wirte files in reverse ?
    tac ${interestingFile%%.*}.blasttemp2.txt | sed '/0 hits/I,+3 d' |tac > ${interestingFile%%.*}.blast.txt

    if [ -s "${interestingFile%%.*}.blast.txt" ]
    then
        rm ${interestingFile%%.*}.blasttemp.txt ${interestingFile%%.*}.blasttemp2.txt
    else
        echo "${interestingFile%%.*}.blast.txt not generated. Available storage space could be the reason !"
    fi
done

# Deactivate conda.
source deactivate
