'''
Program to download all fasta sequences of database from the accesion list.
'''

# coding: utf-8

import os.path
import sys
import argparse
from Bio import Entrez

def check_is_file_exist(file):
    """ Check if the file exists. """
    if os.path.isfile(file):
        print("File exist")
    else:
        print("File not exist")
        sys.exit(1)

def get_id_accession_list(file):
    """ Return a list of ID from accession list. """
    with open(file, "r") as accession_file:
        id_list = accession_file.read().splitlines()
    return id_list

def create_fastq_from_accession_list(basename_output_fastq, id_accession_list):
    """ Create a fastq file from the id list of accesion list file. """

    # Get the extention of basename_output_fastq.
    file_name, extention = os.path.splitext(basename_output_fastq)

    # Verified is the extention of basename_output_fastq is a fastq.
    if extention is None or extention != ".fastq":
        basename_output_fastq = file_name+".fastq"

    # Add mail for ncbi service.
    Entrez.email = "test@exemple.org"

    # Create the fastq file.
    try:
        with open(basename_output_fastq, "w") as fasta_file:
            for id_fastq in id_accession_list:
                handle = Entrez.efetch(db="nucleotide",
                                       id=id_fastq,
                                       rettype="fasta",
                                       retmode="text")
                # Report of fasta.
                report = handle.read()

                # Write the fasta file.
                fasta_file.write(report)

            # Close the handle.
            handle.close()
    except Exception as e:
        print("Error in writting fasta file")

def arguments():
    """ Method for define all arguments of program """
    parser = argparse.ArgumentParser(description="Get database from accession list")
    parser.add_argument("-id",
                        help="Accession list file (.seq)",
                        type=str)
    parser.add_argument("-o",
                        help="Basename of output fastq file.",
                        type=str)
    args = parser.parse_args()
    return args.id, args.o

if __name__ == "__main__":
    print("Download database and all fasta files with the accession list.")

    # Get the first argument with accession list file and name of output fasta file.
    ACCESSION_LIST_FILE, BASENAME_OUTPUT_FASTA = arguments()

    # Check if accesion list exist.
    check_is_file_exist(ACCESSION_LIST_FILE)

    # Recover all id from accesion file.
    ID_LIST = list()
    ID_LIST = get_id_accession_list(ACCESSION_LIST_FILE)

    # Create a fastq file from accession list.
    create_fastq_from_accession_list(BASENAME_OUTPUT_FASTA, ID_LIST)
