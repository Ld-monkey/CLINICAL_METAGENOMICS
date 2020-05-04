#!/usr/bin/env python3
#coding: utf-8

import re
import os
import math
import sys

from ete3 import NCBITaxa

ncbi = NCBITaxa()

entFile=sys.argv[1]

#==== Adds the name of bacterial species, and write it in "count.txt" file ====#
count=open(entFile.replace("bis",""),'w')
with open(entFile) as countFile:
    line = countFile.readline()
    while line:
        split=re.split(' ',line.strip(' '))
        taxID=split[0].strip('\n')
        countReads=split[1]+','+split[2]+','+split[3].strip('\n')
        taxNameDic=ncbi.get_taxid_translator([taxID])
        lineage=ncbi.get_lineage(taxID)
        ranks=ncbi.get_rank(lineage)
        realspecie=-1
        for k in ranks:
            if ranks[k]=='species':
                realspecie=k
        if (realspecie != -1):
            taxid2name = ncbi.get_taxid_translator([realspecie])[realspecie]
        else:
            taxid2name = "Unknown specie"
        taxName=taxNameDic[list(taxNameDic.keys())[0]]
        count.write(taxID+','+taxName.replace(",","_")+','+countReads+','+taxid2name+','+str(realspecie)+'\n')
        line = countFile.readline()
count.close()
