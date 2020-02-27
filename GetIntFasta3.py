#!/usr/bin/env python3
#coding: utf-8

import re
import os
import math
import sys

entFolder=sys.argv[1]
entFile=sys.argv[2]
sampleID=re.split('\\.report',entFile)[0]
kingdomSearched=sys.argv[3]

#==== Name of both ends for the list of taxon ID ====#
if kingdomSearched == "Viruses":
    endSearched=["Archaea","Bacteria","Eukaryota","other sequences","cellular organisms","Fungi"]
    outputFolder="Viruses"
elif kingdomSearched == "Bacteria":
    endSearched=["Archaea","Viruses","Eukaryota","other sequences","cellular organisms","Fungi"]
    outputFolder="Bacteria"
elif kingdomSearched == "Fungi":
    endSearched=["Archaea","Viruses","Eukaryota","other sequences","cellular organisms","Bacteria"]
    outputFolder="Fungi"
else:
    print("Error : Not a valid Kingdom Name")
    sys.exit()

if not os.path.exists(os.path.join(entFolder,outputFolder)): ## Creates Viruses/Bacteria directory if it doesn't exist
    os.mkdir(os.path.join(entFolder,outputFolder))

switchVir=0
outList=[]
subset=[]
print("Sample : " + sampleID)

#==== List all the taxon ID between the defined names in the report file of Kraken2 ====#
with open(os.path.join(entFolder,entFile)) as reportFile:
    ligne=reportFile.readline()
    while ligne:
        if switchVir!=1: ## File is read until a line contains "Viruses" or "Bacteria"
            if len(re.findall(kingdomSearched,ligne))>=1: ## From this line, all taxon ID are registered in the 'subset' list
                switchVir=1
                hashed=re.split(r'\t',ligne)
                if(hashed[2]!='0'):
                    member=[hashed[4],hashed[5].lstrip()[:-1]]
                    subset.append(hashed[4])
                    outList.append(member)
        else: ## All taxon ID are registered until a line which contains one of the 'endSearched' words
            if any(stopNode in ligne for stopNode in endSearched):
                break
            hashed=re.split(r'\t',ligne)
            if(hashed[2]!='0'):
                member=[hashed[4],hashed[5].lstrip()[:-1]]
                subset.append(hashed[4])
                outList.append(member)
        ligne=reportFile.readline()

print("Generation of the list of species of interest : Done\n")
print("Generation of the new ReadsList : Proceeding...\n")

#==== Recover all read names matching with the list of taxon ID ====#
outputFile=open(os.path.join(entFolder,outputFolder,entFile)+"ReadsList.txt",'w')
with open(os.path.join(entFolder,sampleID)+".output.txt") as clseqFile:
    ligne=clseqFile.readline()
    while ligne:
        TaxID=re.split("\t",ligne)[2]
        ReadName=re.split("\t",ligne)[1]
        if TaxID in subset:
            outputFile.write(ReadName+"\n")
        ligne=clseqFile.readline()
outputFile.close()

print("Generation of the ReadsList : Done\n")
