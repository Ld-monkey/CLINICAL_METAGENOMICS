#!/bin/bash
#$ -N BlastOnlyVir
#$ -cwd
#$ -o outcustomblast.out
#$ -e errcustomblast.err
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
echo "NSLOTS: $NSLOTS"<

# qsub launch_custom_blast.sh {path folder with reads} {path of database} {name of folder for output results blast}
# e.g $qsub launch_custom_blast.sh output_preprocess_reads_clean_FDA_refseq_human_viral /data1/scratch/masalm/LUDOVIC/METAGENOMICS/ALL_RAW_FILES_GENOMES_FDA_ARGOS-2020-02-04/MAKEBLAST_makeblast_database_fda_argos/makeblast_database_fda_argos FDA_ARGOS_BLAST
# e.g $qsub launch_custom_blast.sh output_preprocess_reads_clean_FDA_refseq_human_viral /data1/scratch/masalm/LUDOVIC/METAGENOMICS/16S_DATABASE_REFSEQ/MAKEBLAST_16S/16S 16S_REFSEQ_BLAST

# Activate conda environment.
source activate EnvAntL

# Load the module in the cluster. 
module load blastplus/2.2.31

# Folder containing samples of sequences.
PATH_FOLDER_INPUT=$1

# Path to the custom database.
CUSTOM_DATA_BASE=$2

# Name of output folder and will contain all *.blast.txt files.
BASENAME_OUTPUT_FOLDER=$3

# Move all *.blast files in specific folder.
move_output_blast_to_folder () {
    # Create a folder to put all *.blast.txt files.
    mkdir $BASENAME_OUTPUT_FOLDER
    echo "Create $BASE_OUTPUT_FOLDER"

    # Move all *.blast.txt to specific folder.
    for blast_files in *.blast.txt
    do
        mv $blast_files $BASENAME_OUTPUT_FOLDER
        echo "$blast_files is moved in $BASENAME_OUTPUT_FOLDER folder"
    done    
}

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
        cat $interestingFile | parallel --block 1M --recstart '>' --pipe blastn \
                                        -task megablast -evalue 10e-10 \
                                        -db $CUSTOM_DATA_BASE \
                                        -num_threads 1 \
                                        -outfmt \"7 qseqid sseqid sstart send evalue bitscore slen staxids\" \
                                        -max_target_seqs 1 \
                                        -max_hsps 1 \
                                        > ${interestingFile%%.*}.blasttemp.txt

        # Replace all "processed" to d.
        sed "/\processed\b/d" ${interestingFile%%.*}.blasttemp.txt > ${interestingFile%%.*}.blasttemp2.txt

        # tac : concatenate and write files in reverse ?
        tac ${interestingFile%%.*}.blasttemp2.txt | sed '/0 hits/I,+3 d' |tac > ${interestingFile%%.*}.blast.txt

        # Check if *interestinfFile.fasta.blast.txt exists.
        if [ -s "${interestingFile%%.*}.blast.txt" ]
        then
            # Remove blast temporary files.
            rm ${interestingFile%%.*}.blasttemp.txt ${interestingFile%%.*}.blasttemp2.txt
            echo "Move all blast files in $BASENAME_OUTPUT_FOLDER=$2"

            # Call a function to move all blast files in folder.
            move_output_blast_to_folder

            echo "Move done"           
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

        if [ -s "${interestingFile%%.*}.blast.txt" ]
        then
            echo "The ${interestingFile%%.*}.blast.txt exists."
            echo "Remove basttemp.txt and blasttemp2.txt"

            rm ${interestingFile%%.*}.blasttemp.txt ${interestingFile%%.*}.blasttemp2.txt
            echo "Remove done."
            echo "Move all blast files in $BASENAME_OUTPUT_FOLDER=$2"

            # Call a function to move all blast files in folder.
            move_output_blast_to_folder

            echo "Move done"
        else
            echo "${interestingFile%%.*}.blast.txt not generated. Available storage space could be the reason !"
        fi
    done
else
    echo "Folder Bacteria doesn't exists."
fi

# Deactivate conda.
source deactivate
