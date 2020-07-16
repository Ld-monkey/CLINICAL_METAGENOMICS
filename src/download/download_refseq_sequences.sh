#!/bin/bash

# download_refseq_sequences.sh is a shell script to download sequences from
# refseq database.
#
# e.g bash src/download/download_refseq_sequences.sh \
#          -type_db viral \
#          -type_sq genomic \
#          -path_output data/raw_sequences/refseq_viral/ 


# Function to donwload human refseq sequences.
function download_homo_sapiens {
    # Full name of raw sequence folder.
    DATABASE_OUTPUT=${OUTPUT_FOLDER}${DATABASE}/

    # Create specific folder.
    mkdir -p --verbose $DATABASE_OUTPUT

    echo "Download all bacterial sequences from RefSeq database."
    wget ftp://ftp.ncbi.nlm.nih.gov/refseq/H_sapiens/RefSeqGene/$SEQUENCE \
         --directory-prefix=$DATABASE_OUTPUT
    echo "Download done !"
}


# Function to download viral refseq sequences.
function download_database {

    # Full name of raw sequence folder.
    DATABASE_OUTPUT=${OUTPUT_FOLDER}${DATABASE}/

    # Create specific folder.
    mkdir -p --verbose $DATABASE_OUTPUT

    echo "Download all Homo sapeins sequences from RefSeq database."
    wget ftp://ftp.ncbi.nlm.nih.gov/refseq/release/${DATABASE}/$SEQUENCE \
         --directory-prefix=$DATABASE_OUTPUT
    echo "Download done !"
}


# Function to check the correct -type_db parameter.
function check_type_and_download_database {
    if [[ $TYPE = "bacteria" ]]  \
           ||  [[ $TYPE = "viral" ]] \
           ||  [[ $TYPE = "archaea" ]] \
           ||  [[ $TYPE = "fungi" ]] \
           ||  [[ $TYPE = "invertebrate" ]] \
           ||  [[ $TYPE = "mitochondrion" ]] \
           ||  [[ $TYPE = "plant" ]] \
           ||  [[ $TYPE = "plasmid" ]] \
           ||  [[ $TYPE = "plastid" ]] \
           ||  [[ $TYPE = "protozoa" ]] \
           ||  [[ $TYPE = "vertebrate_mammalian" ]] \
           ||  [[ $TYPE = "human" ]]
    then
        echo "Correct parameter -type_db $TYPE"
        case $TYPE in
            bacteria)
                echo "*   bacteria: RefSeq complete bacterial"

                DATABASE="bacteria"

                # Download bacteria sequences.
                download_database
                ;;
            viral)
                echo "*   viral: RefSeq complete viral"

                DATABASE="viral"

                # Download viral sequences.
                download_database
                ;;
            archaea)
                echo "*   archaea: RefSeq complete archaeal"

                DATABASE="archaea"

                # Download archaea sequences.
                download_database
                ;;
            fungi)
                echo "*   fungi: RefSeq complete fungal"

                DATABASE="fungi"

                # Download fungi sequences.
                download_database
                ;;
            invertebrate)
                echo "*   invertebrate: RefSeq complete invertebrate"

                DATABASE="invertebrate"

                # Download invertebrate sequences.
                download_database
                ;;
            mitochondrion)
                echo "*   mitochondrion: RefSeq complete mitochondrion"

                DATABASE="mitochondrion"

                # Download mitochondrion sequences.
                download_database
                ;;
            plant)
                echo "*   plant: RefSeq complete plant"

                DATABASE="plant"

                # Download plant sequences.
                download_database
                ;;
            plasmid)
                echo "*   plasmid: RefSeq complete plasmid"

                DATABASE="plasmid"

                # Download plasmid sequences.
                download_database
                ;;
            plastid)
                echo "*   plastid: RefSeq complete plastid"

                DATABASE="plastid"

                # Download plastid sequences.
                download_database
                ;;
            protozoa)
                echo "*   protozoa: RefSeq complete protozoa"

                DATABASE="protozoa"

                # Download protozoa sequences.
                download_database
                ;;
            vertebrate_mammalian)
                echo "*   vertebrate_mammalian: RefSeq complete vertebrate_mammalian"

                DATABASE="vertebrate_mammalian"

                # Download vertebrate_mammalian sequences.
                download_database
                ;;
            human)
                echo "*   human: RefSeq complete human"

                DATABASE="human"

                # Download human sequences.
                download_homo_sapiens
                ;;
        esac
    else
        echo "-type_db parameter doesn't correspond to following list :"
        echo -e "
           *   bacteria: RefSeq complete bacterial genomes/proteins
           *   viral: RefSeq complete viral genomes/proteins
           *   archaea: RefSeq complete archaea
           *   fungi: RefSeq complete fungal
           *   invertebrate: RefSeq complete invertebrate
           *   mitochondrion: RefSeq complete mitochondrion
           *   plant: RefSeq complete plant
           *   plasmid: RefSeq complete plasmid
           *   plastid: RefSeq complete plastid
           *   protozoa: RefSeq complete protozoa
           *   vertebrate_mammalian: RefSeq complete vertebrate_mammalian
           *   human: RefSeq complete human
           "
        echo "Error in -type parameter"

        exit 1
    fi
}


# Function to check the correct -type_sq (e.g genomic and or protein)
function check_type_sequence {
    if [[ $BIOMOLECULE = "genomic" ]]  ||  [[ $BIOMOLECULE = "protein" ]]
    then
        echo "Correct parameter -type_sq $BIOMOLECULE"
        case $BIOMOLECULE in
            genomic)
                echo "*   genomic : the complete set of genes in an organism."

                SEQUENCE="*genomic.fna.gz"
                ;;
            protein)
                echo "*   protein : molecules composed of one or more long chains of amino acids."

                SEQUENCE="*protein.faa.gz"
                ;;            
        esac
    else
        # By default it's genomics sequences.
        SEQUENCE="*genomic.fna.gz"
    fi
}


PROGRAM=download_refseq_sequences.sh
VERSION=1.0

DESCRIPTION=$(cat << __DESCRIPTION__

__DESCRIPTION__
           )

OPTIONS=$(cat << __OPTIONS__

## OPTIONS ##
    -type_db         (Input)     Which reference librairie for database (choices: viral, bacteria, human)                  *STR: viral
    -type_sq         (Optional)  What kind of sequences to download. Maybe complementary (choices: genomic and or protein) *STR: genomic
    -path_output     (Output)    The folder of refseq output                                                               *DIR: data/raw_sequences/viral_refseq/
__OPTIONS__
       )

# default options:
TYPE_SEQUENCE="genomic"

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
    echo  "e.g : bash src/download/download_refseq_sequences.sh -type_db viral -type_sq genomic -path_output data/raw_sequences/refseq_viral/ "
    echo -e $USAGE

    exit 1
}

# Check options
while [ -n "$1" ]; do
    case $1 in
        -h)                    USAGE      ; exit 0 ;;
        -type_db)              TYPE_DATABASE=$2    ; shift 2; continue ;;
        -type_sq)              TYPE_SEQUENCE=$2    ; shift 2; continue ;;
        -path_output)          OUTPUT_FOLDER=$2    ; shift 2; continue ;;
        *)       BAD_OPTION $1;;
    esac
done

# For each type of database to download.
for TYPE in ${TYPE_DATABASE}; do
    # For each type of biomolecule.
    for BIOMOLECULE in ${TYPE_SEQUENCE}; do
        # Check type of sequences genomic or protein or other.
        check_type_sequence

        # Check correct parameter and download refseq sequences.
        check_type_and_download_database
    done
done
