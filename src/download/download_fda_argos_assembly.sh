#!/bin/bash

# Download all assembly of fda argos database.
# e.g bash download_fda_argos_assembly.sh \
# -assembly_xml data/assembly/assembly_fda_argos_ncbi_result.xml \
# -path_output data/raw_sequences/fda_argos_assembly_raw_sequences/

PROGRAM=download_fda_argos_assembly.sh
VERSION=1.0

DESCRIPTION=$(cat << __DESCRIPTION__

__DESCRIPTION__
           )

OPTIONS=$(cat << __OPTIONS__

## OPTIONS ##
    -assembly_xml    (input)  The input assembly xml file                        *FILE: assembly_result.xml
    -path_output     (output) The folder of output                               *DIR: output_database/
__OPTIONS__
       )

# default options if they are not defined:
OUTPUT_FOLDER=.

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
    echo "example : bash download_fda_argos_assembly.sh -assembly_xml data/assembly/assembly_fda_argos_ncbi_result.xml -path_output data/raw_sequences/fda_argos_assembly_raw_sequences/"
    echo -e $USAGE

    exit 1
}

# Check options
while [ -n "$1" ]; do
    case $1 in
        -h)                    USAGE      ; exit 0 ;;
        -assembly_xml)         ASSEMBLY_XML=$2     ; shift 2; continue ;;
        -path_output)          OUTPUT_FOLDER=$2    ; shift 2; continue ;;
        *)       BAD_OPTION $1;;
    esac
done

echo "Download fda argos assembly."

# Recovering all links from xml assembly fda argos
ALL_PATH=$(sed -n 's,.*<FtpPath_RefSeq>\(.*\)</FtpPath_RefSeq>,\1,p' \
               $ASSEMBLY_XML)

# Add complete links to download Refseq assembly (GFC).
for LINK_GFC_ASSEMBLY in $ALL_PATH; do

    # Recover the reference into complete link.
    # E.g for : ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/001/525/555/GCF_001525555.1_ASM1
    # recovering only : GCF_001525555.1_ASM1
    GCF_ID=$(echo $LINK_GFC_ASSEMBLY | sed -e 's#.*\/\(\)#\1#')

    # Concatenation.
    FULL_FTP_ALL_GFC_ASSEMBLY+="${LINK_GFC_ASSEMBLY}/${GCF_ID}_genomic.fna.gz "
done

# Download all fda argos GFC (refseq annotation) assembly.
for GFC_ASSEMBLY in $FULL_FTP_ALL_GFC_ASSEMBLY; do
    wget $GFC_ASSEMBLY --directory-prefix $OUTPUT_FOLDER
done

echo "Download done !"
