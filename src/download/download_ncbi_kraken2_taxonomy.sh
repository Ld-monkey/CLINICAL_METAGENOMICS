#!/bin/bash

# This program help to download ncbi taxonomy for using kraken 2 software.
# e.g bash download_ncbi_kraken2_taxonomy.sh \
#    -output_taxonomy data/taxonomy/ncbi_taxonomy/

# Function to download ncbi taxonomy.
function download_ncbi_taxonomy {
    echo "Create taxonomy folder $OUTPUT_TAXONOMY "
    echo "Download NCBI taxonomy in $DBNAME"
    kraken2-build --download-taxonomy --db $OUTPUT_TAXONOMY --use-ftp
    echo "Unzip all data"
    gunzip ${OUTPUT_TAXONOMY}taxonmy/*.gz
    echo "Unzip done !"    
}

PROGRAM=download_ncbi_kraken2_taxonomy.sh
VERSION=1.0

DESCRIPTION=$(cat << __DESCRIPTION__

__DESCRIPTION__
           )

OPTIONS=$(cat << __OPTIONS__

## OPTIONS ##
    -output_taxonomy   (Output) The folder path to download the ncbi taxonomy for kraken 2.                                         *DIR: path_taxonomy/
    -force_download    (Optional) Force to update the folder path of ncbi taxonomy.                                                 *STR: ("yes"/"no")

__OPTIONS__
       )

# default options:
FORCE_DOWNLOAD=no

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
    echo "example : bash download_ncbi_kraken2_taxonomy.sh -output_taxonomy data/taxonomy/ncbi_taxonomy/"
    echo -e $USAGE

    exit 1
}

# Check options
while [ -n "$1" ]; do
    case $1 in
        -h)                    USAGE      ; exit 0 ;;
        -output_taxonomy)      OUTPUT_TAXONOMY=$2  ; shift 2; continue ;;
        -force_download)       FORCE_DOWNLOAD=$2   ; shift 2; continue ;;
        *)       BAD_OPTION $1;;
    esac
done

# Check if force download pararmeter is yes.
if [[ $FORCE_DOWNLOAD == "yes" ]]
then
    # Check if folder already exit
    if [ -d $OUTPUT_TAXONOMY ]
    then
        echo "$OUTPUT_TAXONOMY taxonomy already exits."
        echo "But -force_download is set to yes"
        echo "Force to remove le taxonomy folder to replace it with the new one."

        # Force to remove taxonomy folder.
        rm -rf $OUTPUT_TAXONOMY
        echo "Force remove done !"

        # Then download new taxonomy.
        download_ncbi_taxonomy
    else
        mkdir --verbose --parents $OUTPUT_TAXONOMY

        # Download ncbi tanonomy.
        download_ncbi_taxonomy
    fi
else
    if [ -d $OUTPUT_TAXONOMY ]
    then
        echo "$OUTPUT_TAXONOMY taxonomy already exits."
        echo "But -force_download is set to no by default."
        echo "To remove old taxonomy folder you should to set the parameter to -force_download yes"
        echo "Nothing is downloaded"
    else
        mkdir --verbose --parents $OUTPUT_TAXONOMY

        # Download ncbi tanonomy.
        download_ncbi_taxonomy
    fi
fi
