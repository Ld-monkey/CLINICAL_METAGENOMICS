#coding: utf-8

"""
@author : Zygnematophyce
July. 2020
CLINICAL METAGENOMICS

In order to restrict the sorting to really uncertain attributions,
it was necessary to find a way to compare identifiers
of the same taxonomic level. The complete taxonomy of identifiers
Kraken and BLAST is recovered. From this list of taxa,
a comparison is made at the level of the taxonomic genus: if
taxonomy is similar from genus, attributions
are described as correct, and all information
issued by BLAST are retained. In the event that the genres
taxonomic are different, the read is discarded.

(old name : sort_blasted_seq.py)
"""

import sys
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
    NOT_CONSERVED_SEQUENCES = open(BASENAME_NOT_CONSERVED_SEQ, "w")

    # List of genus level.
    SAME_GENUS_LEVEL = list()

    # List of genus level.
    try:
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
                    We can retrieve the taxonomic id of NCBI which is written
                    in the information output from blast file. E.g in some line :
                    # Query: NB552188:4:H353CBGXC:4:12602:3046:7146 1:N:0:1.
                    """

                    # Get the taxonomic ID of Kraken 2.
                    KRAKEN_TAXONOMIC_ID = re.split("taxid\\|", LINE)[1].strip("\n")
                    print("taxo id : ", KRAKEN_TAXONOMIC_ID)

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

                    if BLAST_TAXON_ID != "N/A":
                        """ Verify if both ID are identical or if 
                        genus of these ID have already been compared. """
                        if BLAST_TAXON_ID == KRAKEN_TAXONOMIC_ID or \
                           str(KRAKEN_TAXONOMIC_ID+",and,"+BLAST_TAXON_ID) \
                           in SAME_GENUS_LEVEL:

                            # Write in output file for conserved sequences.
                            CONSERVED_SEQUENCES.write('\t'.join(LINE.split())
                                                     +'\t'
                                                     +KRAKEN_TAXONOMIC_ID
                                                     +'\t'
                                                     +IS_MATE
                                                     +'\n')
                        else:

                            """Gets genus for both taxonID, compares them and if
                            they are the same, adds both taxonID to 
                            'SAME_GENUS_LEVEL' list """
                            
                            # Find the lineage list with the Kraken taxonomic ID.
                            LINEAGE_KRAKEN = NCBI_TAXA.get_lineage(KRAKEN_TAXONOMIC_ID)

                            # Test Lineage_kraken variable.
                            print("LINEAGE : {}".format(LINEAGE_KRAKEN))


                            # Check if lineage list is empty based on the fact
                            # that empty sequences are false.
                            if not LINEAGE_KRAKEN:
                                print("The lineage list is empty.")
                                continue

                            # Get the rank of kraken lineage.
                            RANKS_KRAKEN = NCBI_TAXA.get_rank(LINEAGE_KRAKEN)
                            
                            # Test RANKS_KRAKEN variable.
                            print("RANKS_KRAKEN : {}".format(RANKS_KRAKEN))

                            # Variable for the genus level of KRAKEN.
                            GENUS_KRAKEN = -1
                            GENUS_KRAKEN = [k for k, v in RANKS_KRAKEN.items() if v == 'genus']

                            # Test GENUS_KRAKEN.
                            print("GENUS_KRAKEN : {}".format(GENUS_KRAKEN))

                            # Find the lineage list with the blast taxonomic ID.
                            LINEAGE_BLAST = NCBI_TAXA.get_lineage(BLAST_TAXON_ID)

                            # Test Lineage blast variable.
                            print("LINEAGE_BLAST : {}".format(LINEAGE_BLAST))

                            # Get the rank of blast lineage.
                            RANKS_BLAST = NCBI_TAXA.get_rank(LINEAGE_BLAST)

                            # Test ranks blast.
                            print("RANKS_BLAST {}".format(RANKS_BLAST))

                            # Variable for the genus level of blast.
                            GENUS_BLAST = -2
                            GENUS_BLAST = [k for k, v in RANKS_BLAST.items() if v == 'genus']

                            # Test GENUS_BLAST variable.
                            print("GENUS_BLAST : {}".format(GENUS_BLAST))

                            # Check if genus level are the same for Kraken and Blast.
                            if GENUS_KRAKEN == GENUS_BLAST:
                                # Write in output file for conserved sequences.
                                CONSERVED_SEQUENCES.write('\t'.join(LINE.split())
                                                         +'\t'
                                                         +KRAKEN_TAXONOMIC_ID
                                                         +'\t'
                                                         +IS_MATE
                                                         +'\n')

                                # Add in SAME_GENUS_LEVEL list the taxons.
                                SAME_GENUS_LEVEL.append(str(KRAKEN_TAXONOMIC_ID
                                                            +",and,"
                                                            +BLAST_TAXON_ID))
                            else:
                                # Write in output file for not conserved sequences.
                                NOT_CONSERVED_SEQUENCES.write('\t'.join(LINE.split())
                                                             +'\n')
                    else:
                        # Write in output file for not conserved sequences.
                        NOT_CONSERVED_SEQUENCES.write('\t'.join(LINE.split())+'\n')
                # Read new line.
                LINE = blast_file.readline()
    except FileNotFoundError as error:
        sys.exit(error)
        
    # Close conserved sequences file.
    CONSERVED_SEQUENCES.close()

    # Close not conserved sequences file.
    NOT_CONSERVED_SEQUENCES.close()
