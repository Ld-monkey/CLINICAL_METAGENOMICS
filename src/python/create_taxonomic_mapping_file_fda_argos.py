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
import subprocess


def arguments():
    """ Method that define all arguments ."""

    parser = argparse.ArgumentParser(description="get_list_of_classified_organism.py")

    parser.add_argument("-path_seq",
                        help="(Input) Folder of all raw sequences",
                        type=str)
    parser.add_argument("-output_taxid_map",
                        help="(Output) The path of the output text file which will" \
                        " contain only the classified sequences",
                        type=str)
    args = parser.parse_args()

    return args.path_seq, args.output_taxid_map


def create_output_folder(filename):
    """ Method that create output folder."""

    if not os.path.exists(os.path.dirname(filename)):
        try:
            os.makedirs(os.path.dirname(filename))
        except OSError as exc:
            if exc.errno != errno.EEXIST:
                raise

def get_all_ncbi_genome_accession(path_sequences):
    """ Method that return a list with all ncbi genome accession. """
    
    # List all file from path_sequences.
    list_all_sequences = [f for f in listdir(path_sequences) if isfile(join(path_sequences, f))]

    # Find fasta information after >.
    id_ncbi_genome_accession = list()

    # Get list of id genbank fda argos.
    for i in range(len(list_all_sequences)):
        with open(path_sequences+list_all_sequences[i]) as fasta:
            lines = fasta.readlines()
            for line in lines:
                if line.startswith(">"):
                    splitted_line = line.split()[0].strip(">")
                    id_ncbi_genome_accession.append(splitted_line)

    print("Get all ncbi genome accession of FDA ARGOS done !")
    return id_ncbi_genome_accession


def create_taxonomic_mapping_file(path_taxid_map, list_genome_accession):
    """ Method to create taxonomic mapping file and unmapped file. """

    # Create a unmapped file.
    unmapped_taxid = os.path.dirname(path_taxid_map) + "/unmapped_id.txt"
    
    # Write a taxinomic mapping file and unmapped map file.
    with open(path_taxid_map, "w") as taxid_map_file:
        with open(unmapped_taxid, "w") as unmapped_file:
            for query_id in list_genome_accession:
                result = subprocess.check_output(["esearch -db nuccore -query "+query_id+" | elink -target taxonomy | esummary | xtract -pattern DocumentSummary -element TaxId"], shell=True)
                if result == b'':
                    print("Unmapped {}".format(query_id))
                    unmapped_file.write(query_id+"\n")
                else:
                    line_taxid_map="{} {}".format(query_id, int(result))
                    taxid_map_file.write(line_taxid_map+"\n")                    
                  
    print("taxid map done !")


if __name__ == "__main__":

    print("Create a taxid map for Kraken2 database")

    # Get all arguements.
    PATH_SEQUENCES, TAXID_MAP_OUTPUT = arguments()

    # Create list for ncbi genome accession.
    LIST_NCBI_GENOME_ACCESSION = list()
    
    # Get all ncbi genome accessions.
    LIST_NCBI_GENOME_ACCESSION = get_all_ncbi_genome_accession(PATH_SEQUENCES)

    # Create output folder.
    create_output_folder(TAXID_MAP_OUTPUT)

    # Create taxnomic mapping file.
    create_taxonomic_mapping_file(TAXID_MAP_OUTPUT, LIST_NCBI_GENOME_ACCESSION)
