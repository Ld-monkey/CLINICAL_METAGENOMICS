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

import re
import os
import math
import sys

# Input folder wich contains .report.txt files.
INPUT_FOLDER = sys.argv[1]

# One .report.txt file.
REPORT_FILE = sys.argv[2]

#
SAMPLE_ID = re.split('\\.report', REPORT_FILE)[0]

""" This final argument is limited by 3 propositions "Viruses"
or "Bacteria" or "Fungi".
"""
SELECTED_TAXON = sys.argv[3]

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
    print("e.g : Viruses or Bacteria or Fungi")
    sys.exit()

# Check if INPUT_FOLDER/Viruses or Bacteria or Fungi folders doesn't exist.
if not os.path.exists(os.path.join(INPUT_FOLDER, OUTPUT_FOLDER)):
    os.mkdir(os.path.join(INPUT_FOLDER, OUTPUT_FOLDER))

#
switchVir = 0

#
outList = list()

# Subset of what ?
SUBSET = list()
print("Sample : " + SAMPLE_ID)

"""
List all the taxon ID between the defined
names in the report.txt file of Kraken 2.
"""
with open(os.path.join(INPUT_FOLDER, REPORT_FILE)) as report_files:
    LINE = report_files.readline()
    while LINE:
        # File is read until a LINE contains "Viruses" or "Bacteria"
        if switchVir!=1:
            if len(re.findall(SELECTED_TAXON, LINE))>=1: ## From this LINE, all taxon ID are registered in the 'SUBSET' list
                switchVir=1
                hashed=re.split(r'\t',LINE)
                if(hashed[2]!='0'):
                    member=[hashed[4],hashed[5].lstrip()[:-1]]
                    SUBSET.append(hashed[4])
                    outList.append(member)
        else: ## All taxon ID are registered until a LINE which contains one of the 'UNSELECTED_TAXON' words
            if any(stopNode in LINE for stopNode in UNSELECTED_TAXON):
                break
            hashed=re.split(r'\t',LINE)
            if(hashed[2]!='0'):
                member=[hashed[4],hashed[5].lstrip()[:-1]]
                SUBSET.append(hashed[4])
                outList.append(member)
        LINE=report_files.readline()

print("Generation of the list of species of interest : Done\n")
print("Generation of the new ReadsList : Proceeding...\n")

#==== Recover all read names matching with the list of taxon ID ====#
outputFile=open(os.path.join(INPUT_FOLDER, OUTPUT_FOLDER, REPORT_FILE)+"ReadsList.txt",'w')
with open(os.path.join(INPUT_FOLDER, SAMPLE_ID)+".output.txt") as clseqFile:
    LINE=clseqFile.readline()
    while LINE:
        TaxID=re.split("\t",LINE)[2]
        ReadName=re.split("\t",LINE)[1]
        if TaxID in SUBSET:
            outputFile.write(ReadName+"\n")
        LINE=clseqFile.readline()
outputFile.close()

print("Generation of the ReadsList : Done\n")
