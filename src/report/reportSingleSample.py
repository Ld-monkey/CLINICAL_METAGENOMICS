#!/usr/bin/env python3
#coding: utf-8

import re
import os
import math
import sys
import warnings
import time
import numpy as np
from jinja2 import Environment, FileSystemLoader

class VirusTable:
    def __init__(self,virusid,virusname,verified,kraken,rpmverified,rpmkraken,coverage,score,genus):
      self.VirusID = virusid
      self.VirusName = virusname
      self.ConservedReads = verified
      self.NotConservedReads = kraken
      self.ConservedRPM = rpmverified
      self.NotConservedRPM = rpmkraken
      self.PercentCoverage = coverage
      self.Score = score
      self.Genus = genus

class BacteriaTable:
    def __init__(self,bacteriaid,bacterianame,bacteriagenus,verified,uniqhit,targets):
        self.BacteriaID = bacteriaid
        self.BacteriaName = bacterianame
        self.BacteriaGenus = bacteriagenus
        self.ConservedReads = verified
        self.UniqHit = uniqhit
        self.NbTargets = targets

class InfoTable:
    def __init__(self,nbtotal,preprocess,classified,human,percenthuman,bacteria,percentbacteria,viruses,percentviruses):
        self.NbReadsTotal = nbtotal
        self.Preprocess = preprocess
        self.Classified = classified
        self.Human = human
        self.percentHuman = percenthuman
        self.Bacteria = bacteria
        self.percentBacteria = percentbacteria
        self.Viruses = viruses
        self.percentViruses = percentviruses

class GenusTableSum:
    def __init__(self,genusname,readssample):
        self.GenusName = genusname
        self.ReadsSample = readssample


inputFolder=sys.argv[1]
VirusesFolder=os.path.join(inputFolder,"Viruses")
BacteriaFolder=os.path.join(inputFolder,"Bacteria")
sampleList=[]

for file in os.listdir(VirusesFolder):
    if file.endswith(".count.txt"):
        sampleName=re.split(".count.txt",file)[0]
        sampleList.append(sampleName)

for file in os.listdir(inputFolder):
    if file.endswith(".info.txt") and sampleName in file:
        infoFileSuffix=re.split(sampleName,file)[1]


for sampleName in sampleList:
    with open(os.path.join(inputFolder,sampleName)+infoFileSuffix) as Sampleinfo:
        line=Sampleinfo.readlines()
        nbtotal=line[0].strip('\n')
        preprocess=line[1].strip('\n')
        classified=line[2].strip('\n')
        human=line[3].strip('\n')
        percenthuman=round((int(human)/int(preprocess)*100),2)
        bacteria=line[4].strip('\n')
        percentbacteria=round((int(bacteria)/int(preprocess)*100),2)
        viruses=line[5].strip('\n')
        percentviruses=round((int(viruses)/int(preprocess)*100),2)
        SampleInfoTable=InfoTable(nbtotal,preprocess,classified,human,percenthuman,bacteria,percentbacteria,viruses,percentviruses)

    SampleVirusTable=[]
    GenusTableVir=[]
    GenusVirusTable={}
    with open(os.path.join(VirusesFolder,sampleName)+".count.txt") as SamplecountVir:
        line = SamplecountVir.readline()
        while line:
            split=re.split(",",line)
            id=split[0]
            name=split[1]
            genus=split[6].strip("\n")
            verified=split[2]
            if int(verified) >= 5:
                kraken=split[3]
                rpmverified=round((int(split[2])/int(SampleInfoTable.Preprocess)*1000000),3)
                rpmkraken=round((int(split[3])/int(SampleInfoTable.Preprocess)*1000000),3)
                coverage=float(split[4])
                rpkm=(int(split[2])/int(SampleInfoTable.Preprocess)*1000000)/int(split[5].strip("/n"))
                score=np.log(rpmverified*coverage)
                VirusToAdd=VirusTable(id,name,verified,kraken,rpmverified,rpmkraken,coverage,score,genus)
                SampleVirusTable.append(VirusToAdd)
                if genus in GenusVirusTable:
                    GenusVirusTable[genus]+=int(verified)
                else:
                    GenusVirusTable[genus]=int(verified)
            line = SamplecountVir.readline()
    for genusRow in GenusVirusTable:
        genusName=genusRow
        genusReads=GenusVirusTable[genusRow]
        genusTableRow=GenusTableSum(genusName,genusReads)
        GenusTableVir.append(genusTableRow)

    SampleBacteriaTable=[]
    GenusTable=[]
    try:
        GenusBacteriaTable={}
        with open(os.path.join(BacteriaFolder,sampleName)+".count.txt") as SamplecountBac:
            line = SamplecountBac.readline()
            while line:
                split=re.split(",",line)
                id=split[0]
                name=split[1]
                genus=re.split(" ",name)[0]
                verified=split[2]
                if int(verified) >= 5:
                    uniqhit=split[3]
                    targets=split[4].strip("\n")
                    BacteriaToAdd=BacteriaTable(id,name,genus,verified,uniqhit,targets)
                    SampleBacteriaTable.append(BacteriaToAdd)
                    if genus in GenusBacteriaTable:
                        GenusBacteriaTable[genus]+=int(verified)
                    else:
                        GenusBacteriaTable[genus]=int(verified)
                line = SamplecountBac.readline()

        for genusRow in GenusBacteriaTable:
            genusName=genusRow
            genusReads=GenusBacteriaTable[genusRow]
            genusTableRow=GenusTableSum(genusName,genusReads)
            GenusTable.append(genusTableRow)

    except:
        print("No bacteria analysis")

    file_loader = FileSystemLoader('templates')
    env = Environment(loader=file_loader)
    template =env.get_template('page2.html')
    output = template.render(sampleName=sampleName,listOfVirusesToShow=SampleVirusTable,listOfBacteriaToShow=SampleBacteriaTable,Table1Fill=SampleInfoTable,GenusTable=GenusTable,GenusTableVir=GenusTableVir)
    Page2=open(os.path.join(inputFolder,sampleName)+"report.html","w")
    Page2.write(output)
    Page2.close()
