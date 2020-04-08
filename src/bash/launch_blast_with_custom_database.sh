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

# qsub launch_blast_with_custom_database.sh {path_database} {folder_with_sequences}
# qsub launch_blast_with_custom_database.sh ALL_RAW_FILES_GENOMES_FDA_ARGOS-2020-02-04/MAKEBLAST_makeblast_database_fda_argos/makeblast_database_fda_argos output_preprocess_reads_clean_FDA_refseq_human_viral FDA_ARGOS_BLAST
# qsub launch_blast_with_custom_database.sh /data1/scratch/masalm/LUDOVIC/METAGENOMICS/16S_DATABASE_REFSEQ/MAKEBLAST_16S/16S output_preprocess_reads_clean_FDA_refseq_human_viral 16S_REFSEQ_BLAST

# Activate conda environment.
source activate EnvAntL

# Load in conda the module.
module load blastplus/2.2.31

# Path of the database.
CUSTOM_DATA_BASE=$1

# Folder containing samples of sequences.
PATH_FOLDER_INPUT=$2

# Name of output folder database.
NAME_OUTPUT_DATABASE=$3

# Check if Viruses folder exists.
if [ -d ${PATH_FOLDER_INPUT}/Viruses ]
then
    echo "Folder Viruses exists."

    # Move in the folder/Viruses.
    cd ${PATH_FOLDER_INPUT}/Viruses

    # Get all interesting files *.interesting.fasta .
    ALL_INTEREST_FASTA_FILES=$(ls | grep -i interesting)

    # For each sample align sequence on database (here RefSeq)
    for interestingFile in ${ALL_INTEREST_FASTA_FILES};
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
        cat $interestingFile | parallel --block 1M --recstart '>' --pipe blastn -task megablast -evalue 10e-10 -db $CUSTOM_DATA_BASE -num_threads 1 -outfmt \"7 qseqid sseqid sstart send evalue bitscore slen staxids\" -max_target_seqs 1 -max_hsps 1 > ${interestingFile%%.*}.blasttemp.txt

        # Replace all "processed" to d.
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
else
    echo "Folder Viruses doesn't exists."
fi

# Check if bacteria folder exists.
if [ -d ${PATH_FOLDER_INPUT}/Bacteria ]
then
    # Check if the output folder database exists.
    if [ -d ${PATH_FOLDER_INPUT}/Bacteria/$NAME_OUTPUT_DATABASE ]
    then
        echo "The $NAME_OUTPUT_DATABASE already exists."
    else
        echo "Create folder ${PATH_FOLDER_INPUT}/Bacteria/$NAME_OUTPUT_DATABASE"
        mkdir ${PATH_FOLDER_INPUT}/Bacteria/$NAME_OUTPUT_DATABASE
        echo "Create done."
    fi
    echo "Folder Bacteria exists."

    # Move in the Bacteria folder.
    cd ${PATH_FOLDER_INPUT}/Bacteria

    # Get all interesting files *.interesting.fasta .
    ALL_INTEREST_FASTA_FILES=$(ls | grep -i interesting)

    # For each sample align sequence on database.
    for interestingFile in ${ALL_INTEREST_FASTA_FILES};
    do
        # test
        echo "interestingFile : $interestingFile"
        echo "interestingFile%%.* : ${interestingFile%%.*}"
        
        # Run the blast program.
        cat $interestingFile | parallel --block 50M --recstart '>' --pipe blastn -task megablast -evalue 10e-10 -db $CUSTOM_DATA_BASE -num_threads 1 -outfmt \"7 qseqid sseqid sstart send evalue bitscore slen staxids\" -max_target_seqs 1 -max_hsps 1 > ${interestingFile%%.*}.blasttemp.txt

        # Replace all "processed" in d.
        sed "/\processed\b/d" ${interestingFile%%.*}.blasttemp.txt > ${interestingFile%%.*}.blasttemp2.txt

        # Concatenate and wirte files in reverse ?
        tac ${interestingFile%%.*}.blasttemp2.txt | sed '/0 hits/I,+3 d' |tac > ${interestingFile%%.*}.blast.txt

        # Move all the .blast.txt in correct folder.
        mv *.blast.txt $NAME_OUTPUT_DATABASE/

        if [ -s $NAME_OUTPUT_DATABASE/"${interestingFile%%.*}.blast.txt" ]
        then
            echo "The ${interestingFile%%.*}.blast.txt exists."
            echo "Remove basttemp.txt and blasttemp2.txt"
            rm ${interestingFile%%.*}.blasttemp.txt ${interestingFile%%.*}.blasttemp2.txt
            echo "Remove done."
        else
            echo "${interestingFile%%.*}.blast.txt not generated. Available storage space could be the reason !"
        fi
    done
else
    echo "Folder Bacteria doesn't exists."
fi

# Deactivate conda.
source deactivate
