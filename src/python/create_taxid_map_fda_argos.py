#coding: utf-8

"""
@author : Zygnematophyce
July. 2020
CLINICAL METAGENOMICS

Creation of a taxid_map file specific to FDA-ARGOS sequences. The taxid_map file
created allows to associate a genbank identifier used by FDA-ARGOS with a taxomic
identifier of ncbi and which can be consulted with the blast algorithm by
specifying the -taxon parameter of the src script /bash/create_blast_database.sh

Use of a taxonomic database can be found at :
ftp://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/

Please note that this program can take several hours to find the correct
taxonomic id.
"""


import argparse
import re
import os
from os import listdir
from os.path import isfile, join


def arguments():
    """ Method that define all arguments ."""

    parser = argparse.ArgumentParser(description="get_list_of_classified_organism.py")

    parser.add_argument("-path_seq",
                        help="(Input) Folder of all raw sequences",
                        type=str)
    parser.add_argument("-accession2taxid",
                        help="(Input) The path of accession2taxid.",
                        type=str)
    parser.add_argument("-output_taxid_map",
                        help="(Output) The path of the output text file which will" \
                        " contain only the classified sequences",
                        type=str)
    args = parser.parse_args()

    return args.path_seq, args.accession2taxid, args.output_taxid_map


def create_output_folder(filename):
    """ Method that create output folder."""

    if not os.path.exists(os.path.dirname(filename)):
        try:
            os.makedirs(os.path.dirname(filename))
        except OSError as exc:
            if exc.errno != errno.EEXIST:
                raise


if __name__ == "__main__":
    print("Create a taxid map for Kraken2 database")

    # Get all arguements.
    PATH_SEQUENCES, ACCESSION_2_TAXID, TAXID_MAP_OUTPUT = arguments() 

    # List all file from path_sequences
    LIST_ALL_SEQUENCES = [f for f in listdir(PATH_SEQUENCES) if isfile(join(PATH_SEQUENCES, f))]

    # Get the first one sequences.
    print(PATH_SEQUENCES+LIST_ALL_SEQUENCES[0])    

    # Find fasta information after >.
    list_genbank_fda_argos = list()

    # Get list of id genbank fda argos.
    for i in range(len(LIST_ALL_SEQUENCES)):
        with open(PATH_SEQUENCES+LIST_ALL_SEQUENCES[i]) as fasta:
            lines = fasta.readlines()
            for line in lines:
                if line.startswith(">"):
                    splitted_line = line.split()[0].strip(">")
                    list_genbank_fda_argos.append(splitted_line)
                

    print(list_genbank_fda_argos)

    # Create output folder.
    create_output_folder(TAXID_MAP_OUTPUT)

    # Write the output_taxid map.
    with open(TAXID_MAP_OUTPUT, "w") as taxid_map:
        # Get the genbank information and compare with fda_argos id.
        with open(ACCESSION_2_TAXID) as accession_taxid:
            lines = accession_taxid.readlines()
            for line in lines:
                if any(genbank_fda_argos_id in line for genbank_fda_argos_id in list_genbank_fda_argos):
                    line_splitted = re.split(r"\t", line)
                    ID_GENBANK = line_splitted[1]
                    ID_NCBI = line_splitted[2]
                    line_taxid_map=str(ID_GENBANK)+" "+str(ID_NCBI)+"\n"
                    print(line_taxid_map)
                    taxid_map.write(line_taxid_map)

    print("taxid map done !")

    # write not find in output error_taxid_map 
