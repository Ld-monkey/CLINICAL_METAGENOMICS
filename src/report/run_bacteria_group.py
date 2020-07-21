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
      self.ConservedNTC = 0
      self.NotConservedNTC = 0
      self.ConservedNTCRPM = 0
      self.NotConservedNTCRPM = 0
      self.CoverageNTC = 0
      self.Score = score
      self.Genus = genus
      self.ScoreNTC = 0

class BacteriaTable:
    def __init__(self,bacteriaid,bacterianame,bacteriagenus,verified,uniqhit,targets):
        self.BacteriaID = bacteriaid
        self.BacteriaName = bacterianame
        self.BacteriaGenus = bacteriagenus
        self.ConservedReads = verified
        self.UniqHit = uniqhit
        self.ConservedNTC = 0
        self.UniqHitNTC = 0
        self.NbTargets = targets

class Page1Table:
    def __init__(self,name,matrix,adnorarn,date,icadn,icarn,vir1,vir2,vir3,bac1,bac2,bac3):
        self.SampleName = name
        self.Matrix = matrix
        self.ADNorARN = adnorarn
        self.Date = date
        self.Ic_Adn = icadn
        self.Ic_Arn = icarn
        self.Vir1 = vir1
        self.Vir2 = vir2
        self.Vir3 = vir3
        self.Bac1 = bac1
        self.Bac2 = bac2
        self.Bac3 = bac3

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
    def __init__(self,genusname,readssample,readsntc):
        self.GenusName = genusname
        self.ReadsSample = readssample
        self.ReadsNTC = readsntc



NTCidentifier = "NEG"
inputFolder=sys.argv[1]
VirusesFolder=os.path.join(inputFolder,"Viruses")
BacteriaFolder=os.path.join(inputFolder,"Bacteria")
sampleList=[]

for file in os.listdir(BacteriaFolder):
    if file.endswith(".count.txt") and NTCidentifier in file:
        NTCName=re.split(".count.txt",file)[0]
    if file.endswith(".count.txt"):
        sampleName=re.split(".count.txt",file)[0]
        sampleList.append(sampleName)

for file in os.listdir(inputFolder):
    if file.endswith(".info.txt") and sampleName in file:
        infoFileSuffix=re.split(sampleName,file)[1]

try:
    SummaryTable=[]
    with open(os.path.join(inputFolder,"run_description.txt")) as summaryFile:
        line=summaryFile.readline()
        while line:
            split=re.split(",",line)
            name=split[0]
            matrix=split[1]
            adnorarn=split[2]
            date=split[3]
            Page1Row=Page1Table(name,matrix,adnorarn,date,"","","","","","","","")
            SummaryTable.append(Page1Row)
            line=summaryFile.readline()
except:
    print("No run_description.txt file found, summary table will lack informations")
    for sampleIt in sampleList:
        name=sampleIt
        Page1Row=Page1Table(name,"","","","","","","","","","","")
        SummaryTable.append(Page1Row)

try:
    with open(os.path.join(inputFolder,NTCName)+infoFileSuffix) as NTCinfo:
        line=NTCinfo.readlines()
        nbtotal=line[0].strip('\n')
        preprocess=line[1].strip('\n')
        classified=line[2].strip('\n')
        human=line[3].strip('\n')
        percenthuman=round((int(human)/int(preprocess)*100),2)
        bacteria=line[4].strip('\n')
        percentbacteria=round((int(bacteria)/int(preprocess)*100),2)
        viruses=line[5].strip('\n')
        percentviruses=round((int(viruses)/int(preprocess)*100),2)
        NTCInfoTable=InfoTable(nbtotal,preprocess,classified,human,percenthuman,bacteria,percentbacteria,viruses,percentviruses)


    NTCVirusTable=[]
    GenusVirusTableNTC={}
    with open(os.path.join(VirusesFolder,NTCName)+".count.txt") as NTCcountVir:
        line = NTCcountVir.readline()
        while line:
            split=re.split(",",line)
            id=split[0]
            name=split[1]
            genus=split[6].strip("\n")
            verified=split[2]
            kraken=split[3]
            rpmverified=round((int(split[2])/int(NTCInfoTable.Preprocess)*1000000),3)
            rpmkraken=round((int(split[3])/int(NTCInfoTable.Preprocess)*1000000),3)
            coverage=float(split[4].strip("\n"))
            score=np.log(rpmverified*coverage)
            VirusToAdd=VirusTable(id,name,verified,kraken,rpmverified,rpmkraken,coverage,score,"")
            NTCVirusTable.append(VirusToAdd)
            if genus in GenusVirusTableNTC:
                GenusVirusTableNTC[genus]+=int(verified)
            else:
                GenusVirusTableNTC[genus]=int(verified)
            line = NTCcountVir.readline()

    NTCBacteriaTable=[]
    GenusBacteriaTableNTC={}
    Uniq_specie_NTC={}
    with open(os.path.join(BacteriaFolder,NTCName)+".count.txt") as NTCcountBac:
        line = NTCcountBac.readline()
        while line:
            split=re.split(",",line)
            id=split[0]
            name=split[1]
            specieID=split[6].strip("\n")
            genus=re.split(" ",name)[0]
            verified=split[2]
            uniqhit=split[3]
            targets=split[4]
            if specieID in Uniq_specie_NTC:
                Uniq_specie_NTC[specieID]["verified"]+=int(verified)
                Uniq_specie_NTC[specieID]["uniqhit"]+=int(uniqhit)
                Uniq_specie_NTC[specieID]["targets"]+=int(targets)
            else:
                Uniq_specie_NTC[specieID]={"id":id,"name":speciename,"genus":genus,"verified":int(verified),"uniqhit":int(uniqhit),"targets":int(targets)}
            if genus in GenusBacteriaTableNTC:
                GenusBacteriaTableNTC[genus]+=int(verified)
            else:
                GenusBacteriaTableNTC[genus]=int(verified)
            line = NTCcountBac.readline()
        for specieR in Uniq_specie_NTC:
            BacteriaToAdd=BacteriaTable(Uniq_specie_NTC[specieR]["id"],Uniq_specie_NTC[specieR]["name"],Uniq_specie_NTC[specieR]["genus"],Uniq_specie_NTC[specieR]["verified"],Uniq_specie_NTC[specieR]["uniqhit"],Uniq_specie_NTC[specieR]["targets"])
            NTCBacteriaTable.append(BacteriaToAdd)
except:
    print("No sample tagged as NTC")
    NTCInfoTable=InfoTable("0","0","0","0","0","0","0","0","0")
    NTCVirusTable=[]
    NTCBacteriaTable=[]

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
    print(sampleName) ##### To DELETE
    try:
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
                    print(name+" : "+ str(score)) ##### To DELETE
                line = SamplecountVir.readline()
        for genusRow in GenusVirusTable:
            genusName=genusRow
            genusReads=GenusVirusTable[genusRow]
            try:
                NTCReads=GenusVirusTableNTC[genusRow]
            except:
                NTCReads=0
            genusTableRow=GenusTableSum(genusName,genusReads,NTCReads)
            GenusTableVir.append(genusTableRow)
    except:
        print("No virus analysis")

    SampleBacteriaTable=[]
    GenusTable=[]
    Uniq_specie={}
    try:
        GenusBacteriaTable={}
        with open(os.path.join(BacteriaFolder,sampleName)+".count.txt") as SamplecountBac:
            line = SamplecountBac.readline()
            while line:
                split=re.split(",",line)
                id=split[0]
                name=split[1]
                specieID=split[6].strip("\n")
                speciename=re.split(" ",name)[0]+" "+re.split(" ",name)[1]
                genus=re.split(" ",name)[0]
                verified=split[2]
                if int(verified) >= 5:
                    uniqhit=split[3]
                    targets=split[4].strip("\n")
                    if specieID in Uniq_specie:
                        Uniq_specie[specieID]["verified"]+=int(verified)
                        Uniq_specie[specieID]["uniqhit"]+=int(uniqhit)
                        Uniq_specie[specieID]["targets"]+=int(targets)
                    else:
                        Uniq_specie[specieID]={"id":id,"name":speciename,"genus":genus,"verified":int(verified),"uniqhit":int(uniqhit),"targets":int(targets)}
                    if genus in GenusBacteriaTable:
                        GenusBacteriaTable[genus]+=int(verified)
                    else:
                        GenusBacteriaTable[genus]=int(verified)
                line = SamplecountBac.readline()
        for specieR in Uniq_specie:
            BacteriaToAdd=BacteriaTable(Uniq_specie[specieR]["id"],Uniq_specie[specieR]["name"],Uniq_specie[specieR]["genus"],Uniq_specie[specieR]["verified"],Uniq_specie[specieR]["uniqhit"],Uniq_specie[specieR]["targets"])
            SampleBacteriaTable.append(BacteriaToAdd)

        for genusRow in GenusBacteriaTable:
            genusName=genusRow
            genusReads=GenusBacteriaTable[genusRow]
            try:
                NTCReads=GenusBacteriaTableNTC[genusRow]
            except:
                NTCReads=0
            genusTableRow=GenusTableSum(genusName,genusReads,NTCReads)
            GenusTable.append(genusTableRow)

    except:
        print("No bacteria analysis")


    for xa in SampleVirusTable:
        for xb in NTCVirusTable:
            if xa.VirusID == xb.VirusID:
                xa.ConservedNTC = xb.ConservedReads
                xa.NotConservedNTC = xb.NotConservedReads
                xa.ConservedNTCRPM = xb.ConservedRPM
                xa.NotConservedNTCRPM = xb.NotConservedRPM
                xa.CoverageNTC = xb.PercentCoverage
                xa.ScoreNTC = xb.Score

    for ya in SampleBacteriaTable:
        for yb in NTCBacteriaTable:
            if ya.BacteriaID == yb.BacteriaID:
                ya.ConservedNTC = yb.ConservedReads
                ya.UniqHitNTC = yb.UniqHit

    file_loader = FileSystemLoader('templates')
    env = Environment(loader=file_loader)
    template =env.get_template('page2.html')
    output = template.render(sampleName=sampleName,listOfVirusesToShow=SampleVirusTable,listOfBacteriaToShow=SampleBacteriaTable,Table1Fill=SampleInfoTable,GenusTable=GenusTable,GenusTableVir=GenusTableVir)
    Page2=open(os.path.join(inputFolder,sampleName)+"report.html","w")
    Page2.write(output)
    Page2.close()


    for za in SummaryTable:
        if za.SampleName == sampleName:
            za.Vir1 = SampleVirusTable[0].VirusName if len(SampleVirusTable)>=1 else ""
            za.Vir2 = SampleVirusTable[1].VirusName if len(SampleVirusTable)>=2 else ""
            za.Vir3 = SampleVirusTable[2].VirusName if len(SampleVirusTable)>=3 else ""
            za.Bac1 = SampleBacteriaTable[0].BacteriaName if len(SampleBacteriaTable)>=1 else ""
            za.Bac2 = SampleBacteriaTable[1].BacteriaName if len(SampleBacteriaTable)>=2 else ""
            za.Bac3 = SampleBacteriaTable[2].BacteriaName if len(SampleBacteriaTable)>=3 else ""
            break;

file_loader = FileSystemLoader('templates')
env = Environment(loader=file_loader)
template =env.get_template('page1.html')
output = template.render(page1table=SummaryTable)
Page1=open(os.path.join(inputFolder,"summary_report.html"),"w")
Page1.write(output)
Page1.close()
