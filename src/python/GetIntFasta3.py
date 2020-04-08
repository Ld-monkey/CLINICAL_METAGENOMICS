#!/usr/bin/env python3
#coding: utf-8

"""
@author :
Feb. 2020
Metagenomic

GetIntFasta3 is a module to retrieve the taxonomic IDs of interest
in the “report” file, then the reading names associated with these IDs
in the “output” file in a temporary file (ReadsList.txt).
"""

"""
Problème : il selectionne les espèces en fonction du 2eme indices
de la ligne. Et si ce 2ème indices est différent de 2 alors c'est une
espèces. Alors cela peut amener a un problème qui est le suivant.
Pour une quelconque raison un peu récupérer un le genre car le
2ème parameteres est différents de 0 mais par contre sont 3 ème parameteres
indique un genre. En revanche le 2 ème parameteres s'applique pour la plupart
des espèces mais qui on en plus des S1 S en 3 ème position.
"""

import re
import os
import sys

# Input folder wich contains .report.txt files.
INPUT_FOLDER = sys.argv[1]

# The full name of a report.txt file.
FULLNAME_REPORT_FILE = sys.argv[2]

# Basename of the sample.
BASENAME_REPORT_FILE = re.split('\\.report', FULLNAME_REPORT_FILE)[0]

"""
This final argument is limited by 3 propositions "Viruses"
or "Bacteria" or "Fungi".
"""
SELECTED_TAXON = sys.argv[3]

# Boolean condition to focus on sublist of species for selectionned taxon.
IS_IN_SUBLIST_TAXA = False

# Only ID from the species are stocked in list.
ONLY_ID_SPECIES = list()

# Contain all ID and name of the taxon stocked in list.
ALL_ID_AND_TAXA_NAME = list()

print("The full name of sample is : ", FULLNAME_REPORT_FILE)
print("The basename of sample is : ", BASENAME_REPORT_FILE)

"""
Check if the family (SELECTED_TAXON) either "Viruses" or "Bacteria" or "Fungi"
and name of both ends for the list of taxon ID.
"""
if SELECTED_TAXON == "Viruses":
    OUTPUT_FOLDER = "Viruses"

    UNSELECTED_TAXON = [
        "Archaea", "Bacteria", "Eukaryota",
        "other sequences", "cellular organisms",
        "Fungi"
    ]
elif SELECTED_TAXON == "Bacteria":
    OUTPUT_FOLDER = "Bacteria"

    UNSELECTED_TAXON = [
        "Archaea", "Viruses", "Eukaryota",
        "other sequences", "cellular organisms",
        "Fungi"
    ]
elif SELECTED_TAXON == "Fungi":
    OUTPUT_FOLDER = "Fungi"

    UNSELECTED_TAXON = [
        "Archaea", "Viruses", "Eukaryota",
        "other sequences", "cellular organisms",
        "Bacteria"
    ]
else:
    print("Error : Not a valid taxon name")
    print("e.g : Parameter must be Viruses, Bacteria or Fungi .")
    sys.exit()

# Check if INPUT_FOLDER/Viruses or Bacteria or Fungi folders doesn't exist.
if not os.path.exists(os.path.join(INPUT_FOLDER, OUTPUT_FOLDER)):
    os.mkdir(os.path.join(INPUT_FOLDER, OUTPUT_FOLDER))

"""
List all the taxon ID between the defined
names in the report.txt file of Kraken 2.
"""
with open(os.path.join(INPUT_FOLDER, FULLNAME_REPORT_FILE)) as report_files:
    LINE = report_files.readline()
    while LINE:
        # File is reading until a line contains the sectionned taxon.
        if IS_IN_SUBLIST_TAXA is False:
            if len(re.findall(SELECTED_TAXON, LINE)) >= 1:
                # The flag is true we are in the sub-list.
                IS_IN_SUBLIST_TAXA = True

                """
                Retrieves the separated information (hashed) by a tabulation
                on the line containing the selected taxon (SELECTIONED_TAXON).
                All parameters is stocked into list.
                """
                PARAMETERS_TAB_HASHED_TAXON = re.split(r'\t', LINE)
                if PARAMETERS_TAB_HASHED_TAXON[2] != '0':
                    ID_AND_SPECIES = [PARAMETERS_TAB_HASHED_TAXON[4],
                                      PARAMETERS_TAB_HASHED_TAXON[5].lstrip()[:-1]]

                    # Add ID of species in list.
                    ONLY_ID_SPECIES.append(PARAMETERS_TAB_HASHED_TAXON[4])

                    # Add ID and species names in list.
                    ALL_ID_AND_TAXA_NAME.append(ID_AND_SPECIES)
        else:
            # Stop the reading if the line contains unselected taxon.
            if any(stopNode in LINE for stopNode in UNSELECTED_TAXON):
                break

            PARAMETERS_TAB_HASHED_TAXON = re.split(r'\t', LINE)
            if PARAMETERS_TAB_HASHED_TAXON[2] != '0':
                ID_AND_SPECIES = [PARAMETERS_TAB_HASHED_TAXON[4],
                                  PARAMETERS_TAB_HASHED_TAXON[5].lstrip()[:-1]]

                ONLY_ID_SPECIES.append(PARAMETERS_TAB_HASHED_TAXON[4])

                ALL_ID_AND_TAXA_NAME.append(ID_AND_SPECIES)

        LINE = report_files.readline()

print("Generation of the list in ONLY_ID_SPECIES variable containt all ID of \
species of interest : Done")
print("All id of species :\n", ONLY_ID_SPECIES)
print("ALL_ID_AND_TAXA_NAME :\n", ALL_ID_AND_TAXA_NAME)

# Recover all read names matching with the list of taxon ID.
# Maybe it's better to just add BASENAME_REPORT_FILE.
READS_LIST_OUTPUT = open(os.path.join(INPUT_FOLDER,
                                      OUTPUT_FOLDER,
                                      FULLNAME_REPORT_FILE)
                         + "ReadsList.txt", 'w')

print("Generation of the new Reads list : Proceeding\n")

"""
Thank to all specifics ID of specifis taxon (Virus, Bacteria or Fungi) we
create the output file *ReadsList.txt contains mutiples parameters from
other file named *.output.txt.
All parameters are following for e.g :
NB552188:4:H353CBGXC:1:11104:22599:7341
"""
with open(os.path.join(INPUT_FOLDER,
                       BASENAME_REPORT_FILE)+".output.txt") as clseq_file:
    LINE = clseq_file.readline()
    while LINE:
        ID_TAXON = re.split("\t", LINE)[2]
        NAME_READ = re.split("\t", LINE)[1]
        if ID_TAXON in ONLY_ID_SPECIES:
            READS_LIST_OUTPUT.write(NAME_READ+"\n")
        LINE = clseq_file.readline()
READS_LIST_OUTPUT.close()
print("Generation of the ReadsList : Done")
