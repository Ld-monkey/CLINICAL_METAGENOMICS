#coding: utf-8

"""
@author : Zygnematophyce
July. 2020
CLINICAL METAGENOMICS

Recover sequence with conserved classification between Kraken2 and BLAST.
This program allow to separate the sequences : those which have a similar
taxonomy at the genus level are gathered in the file 'conserved.txt' (output).
"""


import re
import os
import argparse
from ete3 import NCBITaxa


def arguments():
    """ Method for define all arguments of program."""
    parser = argparse.ArgumentParser(description="Sort Blasted sequences"
                                     +" depending on Kraken taxonomy")
    parser.add_argument('-path_blast',
                        help="Input must be the result of an analysis by the Blast algorithm",
                        type=str)

    parser.add_argument('-output',
                        help="The output file which will contain the selected taxonomic id",
                        type=str)

    parser.add_argument('-ncbi',
                        help='Localization of NCBI Taxa database',
                        type=str)


    args = parser.parse_args()
    return args.path_blast, args.output, args.ncbi


def create_output_folder(filename):
    """ Method that create output folder."""

    if not os.path.exists(os.path.dirname(filename)):
        try:
            os.makedirs(os.path.dirname(filename))
        except OSError as exc:
            if exc.errno != errno.EEXIST:
                raise


if __name__ == "__main__":
    print("Find same taxonomic ID's between Kraken 2 and Blast.")

    INPUT_FILE_BLAST, BASENAME_OUTPUT_FILE, NCBI_DATABASE = arguments()

    # Display arguments.
    print("INPUT_FILE_BLAST : {}".format(INPUT_FILE_BLAST))
    print("BASENAME_OUTPUT_FILE : {}".format(BASENAME_OUTPUT_FILE))
    print("NCBI_DATABASE : {}".format(NCBI_DATABASE))

    # Get blast full path name wihtout extension.
    # e.g ../2-SCH-LBA-ADN_S2_blast.txt -> ../2-SCH-LBA-ADN_S2_blast
    BLAST_WITHOUT_EXTENSION = os.path.splitext(INPUT_FILE_BLAST)[0]

    print(BLAST_WITHOUT_EXTENSION)

    # Check ncbi parameter.
    if NCBI_DATABASE is None:
        NCBI_TAXA = NCBITaxa()
    else:
        # Dealing with the NCBI taxonomy database.
        NCBI_TAXA = NCBITaxa(dbfile=NCBI_DATABASE)

    # Create output folder.
    create_output_folder(BASENAME_OUTPUT_FILE)

    # The conserved sequences.
    CONSERVED_SEQUENCES = open(BASENAME_OUTPUT_FILE, "w")

    # Basename for not conserved sequences.
    FOLDER_PATH = os.path.dirname(BASENAME_OUTPUT_FILE)
    BASENAME_NOT_CONSERVED_SEQ = FOLDER_PATH+"/"+"no_same_taxonomic_id.txt"
    print(BASENAME_NOT_CONSERVED_SEQ)

    # Not conserved sequences.
    NOT_CONSERVED_SEQUENCE = open(BASENAME_NOT_CONSERVED_SEQ, "w")

    # List of genus level.
    with open(INPUT_FILE_BLAST) as blast_file:

        # Reading line.
        LINE = blast_file.readline()
        #print(LINE.strip())

        #
        while LINE:

            # Boolean condition to find word "Query" in blast file.
            FLAG_QUERY_BOOLEAN = bool(len(re.findall("Query", LINE)))

            # When find the word "Query" in blast file.
            if FLAG_QUERY_BOOLEAN is True:
                print("FLAG_QUERY_BOOLEAN is True")
                print(LINE)

                """
                We can retrieve the taxonomic id of Kraken 2 which is written
                in the information output from blast file. E.g in some line :
                # Query: NB552188:4:H353CBGXC:4:12602:3046:7146 1:N:0:1 kraken:taxid|573
                After kraken:taxid| there is Kraken 2 taxonomic id 573.
                """

                #Get the taxonomic ID of Kraken 2.
                KRAKEN2_TAXON_ID = re.split("taxid\\|", LINE)[1].strip("\n")
                print("taxo id : ", KRAKEN2_TAXON_ID)

                # Recover fisrt element of 1:N:0:1 -> 1.
                IS_MATE = re.split(":", re.split(" ", LINE)[3])[0]
                print("mate : ", IS_MATE)

                # Skip 4 lines in the text.
                for i in range(4):
                    LINE = blast_file.readline().strip()
                    print(LINE)

                # Divide blast line based on tab.
                # e.g ['NB552188..',.., '132', '5290279', 'N/A']
                SPLIT_BLAST_LINE = re.split('\t', '\t'.join(LINE.split()))
                print(SPLIT_BLAST_LINE)

                # Get the taxonomic ID of blast.
                BLAST_TAXON_ID = SPLIT_BLAST_LINE[len(SPLIT_BLAST_LINE)-1].strip('\n')
                print(BLAST_TAXON_ID)

                break

            LINE = blast_file.readline()

    # Close conserved sequences file.
    CONSERVED_SEQUENCES.close()

    # Close not conserved sequences file.
    NOT_CONSERVED_SEQUENCE.close()
