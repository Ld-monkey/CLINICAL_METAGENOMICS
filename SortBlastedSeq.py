#!/usr/bin/env python3
#coding: utf-8

import re
import os
import math
import sys
import warnings
import time

from ete3 import NCBITaxa

ncbi = NCBITaxa()

entFolder=sys.argv[1]
entFile=sys.argv[2]
sampleID=re.split('\\.blast.txt',entFile)[0]

conservedSeq=open(os.path.join(entFolder,sampleID)+".conserved.txt",'w')
notconservedSeq=open(os.path.join(entFolder,sampleID)+".notconserved.txt",'w')


#==== Compares genus attribution from BLAST and Kraken ====#
sameGenus=[]
with open(os.path.join(entFolder,entFile)) as blastFile:
    clue=0
    print("Opened file")
    ligne=blastFile.readline()
    while ligne:
        QtaxID=''
        StaxID=''
        queryLigne=len(re.findall("Query: ",ligne))
        if queryLigne==1: ## Get to lines of interest in the blast file
            QtaxID=re.split("taxid\\|",ligne)[1].strip('\n') ## Save Kraken taxon ID in 'QtaxID'
            isItMate='0'
            isItMate=re.split(":",re.split(" ",ligne)[3])[0] ## Which mate is read comming from
            ligne=blastFile.readline()
            ligne=blastFile.readline()
            ligne=blastFile.readline()
            ligne=blastFile.readline()
            trick=re.split('\t','\t'.join(ligne.split()))
            StaxID=trick[len(trick)-1].strip('\n') ## Save Blast taxon ID in 'StaxID'
            if StaxID!="N/A": ## Handles Blast database missing taxon information
                if (StaxID == QtaxID or str(QtaxID+",and,"+StaxID) in sameGenus): ## Verify if both ID are identical or if genus of these ID have already been compared
                    conservedSeq.write('\t'.join(ligne.split())+'\t'+QtaxID+'\t'+isItMate+'\n')
                else: ## Gets genus for both taxonID, compares them and if they are the same, adds both taxonID to 'sameGenus' list.
                    try:
                        lineage1 = ncbi.get_lineage(QtaxID)
                    except:
                        continue
                    ranks1=ncbi.get_rank(lineage1)
                    genus1=-1
                    genus1=[k for k,v in ranks1.items() if v == 'genus']
                    lineage2 = ncbi.get_lineage(StaxID)
                    ranks2=ncbi.get_rank(lineage2)
                    genus2=-2
                    genus2=[k for k,v in ranks2.items() if v == 'genus']
                    if (genus1 == genus2) :
                        conservedSeq.write('\t'.join(ligne.split())+'\t'+QtaxID+'\t'+isItMate+'\n')
                        sameGenus.append(str(QtaxID+",and,"+StaxID))
                    else:
                        notconservedSeq.write('\t'.join(ligne.split())+'\n')
            else:
                notconservedSeq.write('\t'.join(ligne.split())+'\n')
        ligne=blastFile.readline()

conservedSeq.close()
notconservedSeq.close()
