#!/bin/bash

# Create custom kraken 2 database.
# --> 3 outputs files : hash.k2d, opts.k2d, taxo.k2d.
# hash.k2d: Contains the minimizer to taxon mappings.
# opts.k2d: Contains information about the options used to build the database.
# taxo.k2d: Contains taxonomy information used to build the database.
# e.g
# ../bash/create_kraken_database.sh \
#     -path_seq ../../data/raw_sequences/mycocosm_fungi_cds_19_05_2020 \
#     -path_db ../../data/databases/mycocosm_fungi_cds_kraken_database_19_05_2020 \
#     -type_db fungi \
#     -threads $thread
# Official documentation : https://ccb.jhu.edu/software/kraken2/index.shtml?t=manual

# Function to check if the sequence folder exists.
function check_sequence_folder {
    if [ -d $PATH_SEQUENCES ]
    then
        echo "$PATH_SEQUENCES folder already exist."
    else
        echo "Error $PATH_SEQUENCES doesn't exist."
        exit 1
    fi
}

# Function to check if the database folder exists.
function check_database_folder {
    if [ -d $DBNAME ]
    then
        echo "$DBNAME folder already exits."
    else
        mkdir $DBNAME
        echo "Create folder database $DBNAME "
    fi
}

# Function to unzip sequences.
function unzip_sequences {
    
    # Check if the fasta files are already decompressed.
    unzip_files=$(ls $PATH_SEQUENCES/*.gz 2> /dev/null | wc -l)
    if [ "$unzip_files" != "0" ]
    then
        echo "Unzip all files"
        gunzip --verbose $PATH_SEQUENCES/*.gz
        echo "$PATH_SEQUENCES Unzip done !"
    else
        echo "$PATH_SEQUENCES files are already decompressed"
    fi
}

# Function to unzip taxonomy files.
function unzip_ncbi_taxonomy {
    
    # Check if the taxonomy files from database are already decompressed.
    taxonomy_unzip=$(ls $DBNAME/taxonomy/*.gz 2> /dev/null | wc -l)
    if [ "$taxonomy_unzip" != "0" ]
    then
        echo "Unzip all *.gz files"
        gunzip $DBNAME/taxonomy/*.gz
        echo "$DBNAME Unzip *.gz done !"
        tar zcvf $DBNAME/taxonomy/*.tar
        echo "$DBNAME *.tar unziped"
        rm $DBNAME/taxonomy/*.tar
        echo "*.tar files are removed"
    else
        echo "$DBNAME *.gz files are already decompressed"
    fi
}

# Function to download ncbi taxonomy if doesn't exists.
function download_ncbi_taxonomy {
    
    # Check if folder with taxonomy is empty.
    if [ ! "$(ls -A $DBNAME/taxonomy)" ]
    then
        echo "$DBNAME is empty!"
        echo "Download NCBI taxonomy in $DBNAME"
        kraken2-build --download-taxonomy --db $DBNAME --use-ftp
        echo "Unzip all data"
        gunzip $DBNAME/taxonmy/*.gz
        echo "Unzip done !"
    else
        echo "NCBI taxonomy is already exists."
    fi
}

# Function to check the correct -type_db parameter.
function check_type_database {
    if [[ $TYPE_DATABASE = "archaea" ]] \
           ||  [[ $TYPE_DATABASE = "bacteria" ]] \
           ||  [[ $TYPE_DATABASE = "plasmid" ]] \
           ||  [[ $TYPE_DATABASE = "viral" ]]  \
           ||  [[ $TYPE_DATABASE = "human" ]] \
           ||  [[ $TYPE_DATABASE = "fungi" ]] \
           ||  [[ $TYPE_DATABASE = "plant" ]] \
           ||  [[ $TYPE_DATABASE = "protozoa" ]] \
           ||  [[ $TYPE_DATABASE = "nr" ]] \
           ||  [[ $TYPE_DATABASE = "nt" ]] \
           ||  [[ $TYPE_DATABASE = "env_nr" ]] \
           ||  [[ $TYPE_DATABASE = "env_nt" ]] \
           ||  [[ $TYPE_DATABASE = "UniVec" ]] \
           ||  [[ $TYPE_DATABASE = "UniVec_Core" ]]
    then
        echo "From https://ccb.jhu.edu/software/kraken2/index.shtml?t=manual#custom-databases"
        echo "Correct parameter -type_db $TYPE_DATABASE"
        case $TYPE_DATABASE in

            archaea)
                echo "*   archaea: RefSeq complete archaeal genomes/proteins"
                ;;
            bacteria)
                echo "*   bacteria: RefSeq complete bacterial genomes/proteins"
                ;;
            plasmid)
                echo "*   plasmid: RefSeq plasmid nucleotide/protein sequences"
                ;;
            viral)
                echo "*   viral: RefSeq complete viral genomes/proteins"
                ;;
            human)
                echo "*   human: GRCh38 human genome/proteins"
                ;;
            fungi)
                echo "*   fungi: RefSeq complete fungal genomes/proteins"
                ;;
            plant)
                echo "*   plant: RefSeq complete plant genomes/proteins"
                ;;
            protozoa)
                echo "*   protozoa: RefSeq complete protozoan genomes/proteins"
                ;;
            nr)
                echo "*   nr: NCBI non-redundant protein database"
                ;;
            nt)
                echo "*   nt: NCBI non-redundant nucleotide database"
                ;;
            env_nr)
                echo "*   env_nr: NCBI non-redundant protein database with sequences from large environmental sequencing projects"
                ;;
            env_nt)
                echo "*   env_nt: NCBI non-redundant nucleotide database with sequences from large environmental sequencing projects"
                ;;
            UniVec)
                echo "*   UniVec: NCBI-supplied database of vector, adapter, linker, and primer sequences that may be contaminating sequencing projects and/or assemblies"
                ;;
            UniVec_Core)
                echo "*   UniVec_Core: A subset of UniVec chosen to minimize false positive hits to the vector database"
                ;;
        esac
    else
        echo "Take care about official documentation in https://ccb.jhu.edu/software/kraken2/index.shtml?t=manual#custom-databases"
        echo "-type_db parameter doesn't correspond to following list :"
        echo -e "
           *   archaea: RefSeq complete archaeal genomes/proteins
           *   bacteria: RefSeq complete bacterial genomes/proteins
           *   plasmid: RefSeq plasmid nucleotide/protein sequences
           *   viral: RefSeq complete viral genomes/proteins
           *   human: GRCh38 human genome/proteins
           *   fungi: RefSeq complete fungal genomes/proteins
           *   plant: RefSeq complete plant genomes/proteins
           *   protozoa: RefSeq complete protozoan genomes/proteins
           *   nr: NCBI non-redundant protein database
           *   nt: NCBI non-redundant nucleotide database
           *   env_nr: NCBI non-redundant protein database with sequences from large environmental sequencing projects
           *   env_nt: NCBI non-redundant nucleotide database with sequences from large environmental sequencing projects
           *   UniVec: NCBI-supplied database of vector, adapter, linker, and primer sequences that may be contaminating sequencing projects and/or assemblies
           *   UniVec_Core: A subset of UniVec chosen to minimize false positive hits to the vector database
            "
        echo "Error in -type parameter"

        exit 1
    fi    
}

PROGRAM=create_kraken_database.sh
VERSION=1.0

DESCRIPTION=$(cat << __DESCRIPTION__

__DESCRIPTION__
           )

OPTIONS=$(cat << __OPTIONS__

## OPTIONS ##
    -path_seq  (Input) Folder path of other sequences in fna or fasta files                                 *DIR: sequences
    -path_db   (Input) Folder path to create or view the database                                           *DIR: database
    -type_db   (Input) Which reference librairie for db (choices: viral, fungi, bacteria) see offical doc   *STR: fungi
    -threads   (Input) The number of threads to build the datab ase faster                                  *INT: 6
__OPTIONS__
       )

# default options:
threads=1

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
    echo "example : ../bash/create_kraken_database.sh -path_seq ../../data/raw_sequences/mycocosm_fungi_cds_19_05_2020 -path_db ../../data/databases/mycocosm_fungi_cds_kraken_database_19_05_2020 -type_db fungi -threads $thread "
    echo -e $USAGE

    exit 1
}

# Check options
while [ -n "$1" ]; do
    case $1 in
        -h)                    USAGE      ; exit 0 ;;
        -path_seq)             PATH_SEQUENCES=$2    ; shift 2; continue ;;
  	    -path_db)              DBNAME=$2            ; shift 2; continue ;;
        -type_db)              TYPE_DATABASE=$2     ; shift 2; continue ;;
    	  -threads)              threads=$2           ; shift 2; continue ;;
        *)       BAD_OPTION $1;;
    esac
done

echo " ---- Create Kraken 2 Database ---- "

# Check if folder containing sequences exists (-path_seq).
check_sequence_folder

# Check if database folder exists (-path_db).
check_database_folder

# Check the correct parameter (-type_db).
check_type_database

echo $threads

# Unzip fasta or fna files.
unzip_sequences

# First, to build a custom database we install a ncbi taxonomy.
download_ncbi_taxonomy

# Unzip all taxonomy files.
unzip_ncbi_taxonomy

# Second, download kraken 2 genomic library depending on the type of db expected.
if [ -d $DBNAME/library/$TYPE_DATABASE ]
then
    echo "$DBNAME/library/$TYPE_DATABASE folder already exists."
else
    kraken2-build --download-library $TYPE_DATABASE --db $DBNAME

    # Check if kraken-build return a error.
    if [ $? -eq 0 ]; then
        echo "Download kraken2-buil --download-library $TYPE_DATABASE in $DBNAME is done !"
    else
        echo "Error to download library $TYPE_DATABASE"
        exit 1
    fi
fi

# Before adding the sequences to the library, check if the database is not already created hash.k2d + opts.k2d + taxo.k2d .
if [ -f $DBNAME/hash.k2d ] && [ -f $DBNAME/opts.k2d ] && [ -f $DBNAME/taxo.k2d ]
then
    echo "Data Base are already exists."
    echo "All jobs are done in this session !"
else
    echo "Let's create database"

    # Check if format is .fna or .fasta .
    is_fna_format=$(ls $PATH_SEQUENCES/*.fna 2> /dev/null | wc -l)
    is_fasta_format=$(ls $PATH_SEQUENCES/*.fasta 2> /dev/null | wc -l)

    # Third, add others sequences in the database.
    if [ "$is_fna_format" != "0" ]
    then
        echo "Adding reference to Kraken 2 library"
        for fna_file in $PATH_SEQUENCES/*.fna
        do
            kraken2-build --add-to-library $fna_file --db $DBNAME
        done
    else
        echo "No *.fna format"
    fi

    if [ "$is_fasta_format" != "0" ]
    then
        echo "Adding reference to Kraken 2 library"
        for fasta_file in $PATH_SEQUENCES/*.fasta
        do
            kraken2-build --add-to-library $fasta_file --db $DBNAME
        done
    else
        echo "No *.fasta format"
    fi

    # 3) Once library is finalized we need to build the database.
    # parameters --threads to reduce build time.
    echo "Running build program to build database with Kraken 2"
    kraken2-build --build --db $DBNAME --threads $threads
fi

# # 3.1) For remove intermediate file from the database directory
# #kraken2-build --clean
