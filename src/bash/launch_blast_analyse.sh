#!/bin/bash

# From a set of reads and depend of the database gived in argument
# allow to align the sequences with the blast algorithms. 
# e.g $launch_blast_analyse.sh -path_reads sample_reads \
# -path_db FDA_ARGOS_db -path_result blast_metaplan_output

PROGRAM=launch_blast_analyse.sh
VERSION=1.0

DESCRIPTION=$(cat << __DESCRIPTION__

__DESCRIPTION__
           )

OPTIONS=$(cat << __OPTIONS__

## OPTIONS ##
    -path_reads      (Input) folder path of other sequences file fna                                        *DIR: sequences*.fna
    -path_db         (Input)  The path of blast database.                                                   *DIR: input_database
    -path_results    (Output) folder path for blast results                                                 *DIR: blast_result
__OPTIONS__
       )

# default options:

USAGE ()
{
    cat << __USAGE__
$PROGRAM version $VERSION:
$DESCRIPTION
$OPTIONS

__USAGE__
}

BAD_OPTION ()
{
    echo
    echo "Unknown option "$1" found on command-line"
    echo "It may be a good idea to read the usage:"
    echo "white $PROGRAM -h to be helped :"
    echo "example : launch_blast_analyse.sh -path_reads sample_reads -path_db FDA_ARGOS_db -path_result blast_metaplan_output"
    echo -e $USAGE

    exit 1
}

# Check options
while [ -n "$1" ]; do
    case $1 in
        -h)                    USAGE      ; exit 0 ;;
        -path_reads)          PATH_FOLDER_INPUT=$2      ; shift 2; continue ;;
  	    -path_db)             CUSTOM_DATA_BASE=$2       ; shift 2; continue ;;
    	  -path_results)        BASENAME_OUTPUT_FOLDER=$2 ; shift 2; continue ;;
        *)       BAD_OPTION $1;;
    esac
done

# Move all *.blast files in specific folder.
move_output_blast_to_folder () {
    # Create a folder to put all *.blast.txt files.
    mkdir $BASENAME_OUTPUT_FOLDER

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
