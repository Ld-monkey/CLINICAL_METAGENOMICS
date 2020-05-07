'''
Recover sequence with conserved classification between Kraken2 and BLAST.
This program allow to separate the sequences : those which have a similar
taxonomy at the genus level are gathered in the file "conserved.txt" (output).
'''
# coding: utf-8

import re
import os
import argparse
from ete3 import NCBITaxa

def arguments():
    """ Method for define all arguments of program """
    parser = argparse.ArgumentParser(description="Sort Blasted sequences"
                                     +" depending on Kraken taxonomy")
    parser.add_argument('-i',
                        help="Blast input (txt)",
                        type=str)

    parser.add_argument('-o',
                        help='Output file e.g conserved.txt',
                        type=str)

    parser.add_argument('-n',
                        help='Localization of NCBI Taxa database',
                        type=str)

    args = parser.parse_args()
    return args.i, args.o, args.n

if __name__ == "__main__":
    print("-----------------------------------------")
    print("Sort blasted sequences.")

    # * INPUT_FILE_BLAST : Path of Bacteria or Viruses directories
    # with all interresting *.fasta file.
    # * BASENAME_OUTPUT_FILE : Basename of output file (e.g conserved.txt).
    # NCBI_DATABASE : Localization of NCBI taxa database.
    INPUT_FILE_BLAST, BASENAME_OUTPUT_FILE, NCBI_DATABASE = arguments()

    # Display arguments.
    print("INPUT_FILE_BLAST : {}".format(INPUT_FILE_BLAST))
    print("BASENAME_OUTPUT_FILE : {}".format(BASENAME_OUTPUT_FILE))
    print("NCBI_DATABASE : {}".format(NCBI_DATABASE))

    # Because the file contain also the name of input folder
    # e.g 2-SCH-LBA-ADN_S2_.blast.txt -> folder is 2-SCH-LBA-ADN_S2_.
    INPUT_FOLDER_BLAST = os.path.splitext(INPUT_FILE_BLAST)[0]

    # Without extention .blast.txt
    INPUT_WITHOUT_EXTENTION = os.path.splitext(INPUT_FOLDER_BLAST)[0]

    # Folder is for example 2-SCH-LBA-ADN_S2_fasta.
    INPUT_FOLDER_BLAST = INPUT_WITHOUT_EXTENTION+"fasta"
    print("INPUT_FOLDER_BLAST : {}".format(INPUT_FOLDER_BLAST))

    BASENAME_OUTPUT_FILE = re.split('/', BASENAME_OUTPUT_FILE)[-1]
    print("split BASENAME_OUTPUT_FILE : {}".format(BASENAME_OUTPUT_FILE))

    # Dealing with the NCBI taxonomy database.
    NCBI_TAXA = NCBITaxa(dbfile=NCBI_DATABASE)

    # The conserved sequences.
    CONSERVED_SEQUENCE = open(INPUT_FOLDER_BLAST
                              +"/"
                              +BASENAME_OUTPUT_FILE,
                              'w')

    # Basename for not conserved sequences.
    BASENAME_NOT_CONSERVED_SEQ = BASENAME_OUTPUT_FILE.replace('conserved',
                                                              'notconserved')

    # Display the variable for not conserved sequences.
    print("basename of not conserved sequence is : {}".format(BASENAME_NOT_CONSERVED_SEQ))

    # Not conserved sequences.
    NOT_CONSERVED_SEQUENCE = open(INPUT_FOLDER_BLAST
                                  +"/"
                                  +BASENAME_NOT_CONSERVED_SEQ,
                                  "w")
    # List of genus level.
    SAME_GENUS_LEVEL = list()

    # Compares genus attribution from BLAST and Kraken
    with open(INPUT_FILE_BLAST) as blast_file:
        # Display messages.
        print("##########{}##########".format(INPUT_FILE_BLAST))
        print("Opened file {}".format(INPUT_FILE_BLAST))

        # Reading line.
        LINE = blast_file.readline()

        # Test print first line.
        print("Line : {}".format(LINE))

        # Browse the lines of blast file.
        while LINE:
            # Variable that stores the kraken taxonomic ID.
            KRAKEN_TAXONOMIC_ID = ''

            # Variable that stores Blast taxon ID.
            BLAST_TAXON_ID = ''

            # Query: NB552188:4:H353CBGXC:4:22605:9229:16747 1:N:0:10
            # Flag to get line of interest in the blast file.
            FLAG_QUERY_LINE = len(re.findall("Query: ", LINE))

            # Check if Query motif is find in the line.
            if FLAG_QUERY_LINE == 1:

                # e.g kraken:taxid|1747 -> 1747.
                # Save Kraken taxon ID in 'KRAKEN_TAXONOMIC_ID'.
                KRAKEN_TAXONOMIC_ID = re.split("taxid\\|", LINE)[1].strip('\n')

                # Test KRAKEN_TAXONOMIC_ID
                print("KRAKEN_TAXONOMIC_ID : {}".format(KRAKEN_TAXONOMIC_ID))

                # MATE ??
                IS_MATE = '0'

                # Which mate is read comming from ?
                IS_MATE = re.split(":", re.split(" ", LINE)[3])[0]

                # Test for IS_MATE variable.
                print("IS_MATE : {}".format(IS_MATE))

                # WTF !! Reading 4 times new lines.
                LINE = blast_file.readline()
                print("First jump {}".format(LINE))
                LINE = blast_file.readline()
                print("Second jump {}".format(LINE))
                LINE = blast_file.readline()
                print("Third jump {}".format(LINE))
                LINE = blast_file.readline()
                print("Foor jump {}".format(LINE))

                # Split in a list the 4th line.
                # NB552188:4:H353CBGXC:4:22605:9229:16747 ...
                # ['NB552188:4:H353CBGXC:4:22605:9229:16747', ...]
                TRICK = re.split('\t', '\t'.join(LINE.split()))

                # Test Trick variable.
                print("TRICK : {}".format(TRICK))

                # Save blast taxon ID in 'BLAST_TAXON_ID' at the end list of trick.
                BLAST_TAXON_ID = TRICK[len(TRICK)-1].strip('\n')

                # Test BLAST_TAXON_ID variable.
                print("BLAST_TAXON_ID : {}".format(BLAST_TAXON_ID))

                # Handles Blast database missing taxon information (N/A).
                if BLAST_TAXON_ID != "N/A":
                    # Verify if both ID are identical or if genus of these ID
                    # have already been compared.
                    if (BLAST_TAXON_ID == KRAKEN_TAXONOMIC_ID or \
                        str(KRAKEN_TAXONOMIC_ID+",and,"+BLAST_TAXON_ID) \
                        in SAME_GENUS_LEVEL):
                        # Write in output file for conserved sequences.
                        CONSERVED_SEQUENCE.write('\t'.join(LINE.split())
                                                 +'\t'
                                                 +KRAKEN_TAXONOMIC_ID
                                                 +'\t'
                                                 +IS_MATE
                                                 +'\n')
                    else:
                        #Gets genus for both taxonID, compares them and if they are
                        #the same, adds both taxonID to 'SAME_GENUS_LEVEL' list.

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
                            CONSERVED_SEQUENCE.write('\t'.join(LINE.split())
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
                            NOT_CONSERVED_SEQUENCE.write('\t'.join(LINE.split())
                                                         +'\n')
                else:
                    # Write in output file for not conserved sequences.
                    NOT_CONSERVED_SEQUENCE.write('\t'.join(LINE.split())+'\n')
                    # Read new line.
            LINE = blast_file.readline()

    # Close conserved sequences file.
    CONSERVED_SEQUENCE.close()

    # Close not conserved sequences file.
    NOT_CONSERVED_SEQUENCE.close()
