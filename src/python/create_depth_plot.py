#!/usr/bin/env python3
#coding: utf-8

import re
import os
import math
import sys
import matplotlib.pyplot as plt
import numpy as np
from ete3 import NCBITaxa

ncbi = NCBITaxa()

def listOfSizeN(N):
    cover=[0]*(N+1)
    return cover


entFolder=sys.argv[1]
entFile=sys.argv[2]
entFile2=sys.argv[3]
sampleID=re.split('\\.conserved',entFile)[0]

#===== For each taxonID, gets corresponding name of species + Creates first part of the output =====#
lineToCopy=[] ## First part of count.txt output
with open(os.path.join(entFolder,entFile2)) as countFile: ## Open ***.countbis.txt
    dictListSpecies={}
    line = countFile.readline()
    while line:
        split=re.split(' ',line)
        taxID=split[0].strip('\n')
        countReads=split[1]+','+split[2].strip('\n')
        taxNameDic=ncbi.get_taxid_translator([taxID])
        dictListSpecies.update(taxNameDic)
        taxName=taxNameDic[list(taxNameDic.keys())[0]]
        taxName=taxName.replace("/","_")
        lineToCopy.append(taxID+','+taxName+','+countReads)
        line = countFile.readline()

#===== For each specie, create a list of all coordinates of alignment, and draw the plot based on this list =====#
dictListCoverage={}
dictListSizeGenome={}
dictListGenus={}
if not os.path.exists(entFolder+"/Depth_Graphs"+sampleID): ## Creates graph folder if it doesn't exist
    os.mkdir(entFolder+"/Depth_Graphs"+sampleID)
with open(os.path.join(entFolder,entFile)) as conservedSeqFile: ## Open ***.conserved.txt
    ligne=conservedSeqFile.readline()
    while ligne:
        hashed=re.split(r'\t',ligne)
        species=hashed[7].strip('\n')
        lineage=ncbi.get_lineage(species)
        ranks=ncbi.get_rank(lineage)
        genus=-1
        for k in ranks:
            if ranks[k]=='genus':
                genus=k
        speciesTick=hashed[7].strip('\n')
        sizeSubject=int(hashed[6])
        coverList=[]
        coverList=listOfSizeN(sizeSubject) ## List of set size filled with 0
        coordStart=[]
        coordEnd=[]

        while species == speciesTick: ## For each read of the same specie, memorize the coordinates of alignment
            coordStart.append(min(int(hashed[2]),int(hashed[3])))
            coordEnd.append(max(int(hashed[2]),int(hashed[3])))
            ligne=conservedSeqFile.readline()
            hashed=re.split(r'\t',ligne)
            try:
                speciesTick=hashed[7].strip('\n')
            except:
                speciesTick=-1

        for j in range(len(coordStart)): ## List of 0 is being incremented according to previously memorized coordinate
            for i in range (coordStart[j],coordEnd[j]+1):
                try:
                    coverList[i]+=1
                except:
                    print(sampleID)
                    print(species)
                    print(str(range(len(coordStart))))
                    print(str(coordStart[j])+' - '+str(coordEnd[j]+1))
                    print("A bad allocation")

        coveragePercent=str(round(((len(coverList)-coverList.count(0))/len(coverList)*100),5))
        dictListCoverage.update({species: coveragePercent})
        dictListSizeGenome.update({species: str(sizeSubject)})
        if (genus != -1):
            taxid2name = ncbi.get_taxid_translator([genus])[genus]
            dictListGenus.update({species: taxid2name})
        else:
            dictListGenus.update({species: "Unknown Genus"})
        if len(coordStart)>=5: ## Draw the depth/coverage plot following the list
            x=np.arange(len(coverList))
            plt.plot(x,coverList,color="#2d6a9f")
            plt.fill_between(x,0,coverList,facecolor="#609dd2")
            plt.xlim(left=0.0,right=len(coverList))
            plt.ylim(bottom=0.0)
            plt.ylabel('Depth')
            speciesName = dictListSpecies[int(species)]
            speciesName = speciesName.replace("/","_")
            if (genus != -1):
                plt.xlabel(speciesName+" (genus:"+taxid2name+")")
                plt.savefig(entFolder+"/Depth_Graphs"+sampleID+"/"+speciesName+".png",bbox_inches='tight')
            else:
                plt.xlabel(speciesName)
                plt.savefig(entFolder+"/Depth_Graphs"+sampleID+"/"+speciesName+".png",bbox_inches='tight')
            plt.clf()
            print(speciesName+".png generated")

#===== Generate the ***.count.txt, summary of all important informations =====#
count=open(os.path.join(entFolder,entFile2.replace("bis","")),'w')
for line in lineToCopy:
    part1=re.split(',',line)[0]
    count.write(line+','+dictListCoverage[part1]+','+dictListSizeGenome[part1]+','+dictListGenus[part1]+'\n')
count.close()
