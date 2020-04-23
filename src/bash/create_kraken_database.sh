#!/bin/bash

# Create kraken 2 databases (we don't want to download any database !)
# --> 3 outputs files : hash.k2d, opts.k2d, taxo.k2d.
# hash.k2d: Contains the minimizer to taxon mappings.
# opts.k2d: Contains information about the options used to build the database.
# taxo.k2d: Contains taxonomy information used to build the database.

# We don't want to create standard database because we create a custom database.
# e.g create_kraken_database.sh -ref ../../data/FDA_ARGOS \
#    -database /output_FDA_ARGOS -thread 1

PROGRAM=create_kraken_database.sh
VERSION=1.0

DESCRIPTION=$(cat << __DESCRIPTION__

__DESCRIPTION__
           )

OPTIONS=$(cat << __OPTIONS__

## OPTIONS ##
    -ref      (Input) folder path of other sequences file fna                                              *FILE: sequences.fna
    -database (Input) folder path to create or view the database                                           *DIR: database
    -threads  (Input) the number of threads to build the datab ase faster                                   *INT: 6
__OPTIONS__
       )

# default options:
threads=1f

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
    echo "example : ./create_kraken_database.sh -ref test -database database -threads 1"
    echo -e $USAGE

    exit 1
}

# Check options
while [ -n "$1" ]; do
    case $1 in
        -h)                    USAGE      ; exit 0 ;;
        -ref)          PATH_SEQUENCES=$2    ; shift 2; continue ;;
  	    -database)             DBNAME=$2    ; shift 2; continue ;;
    	  -threads)             threads=$2    ; shift 2; continue ;;
        *)       BAD_OPTION $1;;
    esac
done

echo " ---- Kraken 2 ---- "
echo $PATH_SEQUENCES
echo $DBNAME
echo $threads

# Check if the folder for sequences exists.
if [ -d $PATH_SEQUENCES ]
then
    echo "$PATH_SEQUENCES folder already exist."
else
    echo "$PATH_SEQUENCES doesn't exist."
    exit
fi

# Check if the folder for database exists.
if [ -d $DBNAME ]
then
    echo "$DBNAME folder already exits."
else
    mkdir database
    echo "Create folder database "
fi

# Check if the fasta files from database are already decompressed.
unzip_files=$(ls $PATH_SEQUENCES/*.gz 2> /dev/null | wc -l)
if [ "$unzip_files" != "0" ]
then
    echo "Unzip all files"
    gunzip $PATH_SEQUENCES/*.fna.gz
    echo "$PATH_SEQUENCES Unzip done !"
else
    echo "$PATH_SEQUENCES Files are already decompressed"
fi

# Check if the taxonomy files from database are already decompressed.
taxonomy_unzip=$(ls $DBNAME/taxonomy/*.gz 2> /dev/null | wc -l)
if [ "$taxonomy_unzip" != "0" ]
then
    echo "Unzip all files"
    gunzip $DBNAME/taxonomy/*.gz
    echo "$DBNAME Unzip done !"
    tar zcvf $DBNAME/taxonomy/*.tar
    rm $DBNAME/taxonomy/*.tar
    echo "$DBNAME tar unziped"
    echo "files tar removed"
else
    echo "$DBNAME Files are already decompressed"
fi

# 1) To build a custom database we need
# install a taxonomy with NCBI taxonomy

# Check if folder with taxonomy is empty.
if [ ! "$(ls -A $DBNAME/taxonomy)" ]
then
    echo "$DBNAME is empty!"
    echo "Installing NCBI taxonomy in database"
    kraken2-build --download-taxonomy --db $DBNAME --use-ftp
    echo "Unzip all data"
    gunzip $DBNAME/taxonmy/*.gz
    echo "Unzip done !"
else
    echo "NCBI taxonomy is already exists."
fi

# 2) We can add other sequences in the database from fasta files
# maybe all genome in database.

# viral: RefSeq complete viral genomes/proteins
kraken2-build --download-library viral --db $DBNAME

# Before adding the sequences to the library, check if the database is not already created hash.k2d + opts.k2d + taxo.k2d .
if [ -f $DBNAME/hash.k2d ] && [ -f $DBNAME/opts.k2d ] && [ -f $DBNAME/taxo.k2d ]
then
    echo "Data Base are already exists."
    echo "All jobs are done in this session !"
else
    echo "Let's create database"
    # Third argument to define the path to all sequences from other database
    PATH_OTHER_SEQUENCES=$3
    echo "Adding reference to Kraken 2 library"
    for fasta_file in $PATH_SEQUENCES/*.fna
    do
        kraken2-build --add-to-library $fasta_file --db $DBNAME
    done

    # 3) Once library is finalized we need to build the database.
    # parameters --threads to reduce build time.
    echo "Running build program to build database with Kraken 2"
    kraken2-build --build --db $DBNAME --threads $threads
fi

# 3.1) For remove intermediate file from the database directory
#kraken2-build --clean
