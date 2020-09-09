#coding: utf-8

"""
@author : Zygnematophyce
July. 2020
CLINICAL METAGENOMICS

(old name : run.py)
"""


import re
import os
import math
import sys
import warnings
import time
import numpy as np
from jinja2 import Environment, FileSystemLoader


class OrganismTable:
    """ Super class for all organisms. """

    def __init__(self,
                 taxonomic_id,
                 name_organism,
                 conserved_reads,
                 not_conserved_reads,
                 conserved_rpm,
                 not_conserved_rpm,
                 percent_coverage_sequence,
                 score,
                 genus):
        
        self.taxonomic_id = taxonomic_id
        self.name_organism = name_organism

        self.conserved_reads = conversed_reads
        self.not_conserved_reads = not_conserved_reads

        self.conserved_rpm = conserved_rpm
        self.not_conserved_rpm = not_conserved_rpm

        self.percent_coverage_sequence = percent_coverage_sequence

        self.conserved_NTC = 0
        self.not_conserved_NTC = 0
        self.score_NTC = 0

        self.conserved_CRPM = 0
        self.not_conserved_CRPM = 0

        self.corevage_NTC = 0

        self.score = score

        self.genus = genus

        
    def __str__(self):
        return "Organism class"
        

class VirusTable(OrganismTable):
    """ Class for virus organisms. """
    
    def __init__(self,
                 virus_id,
                 virus_name,
                 conserved_reads,
                 not_conserved_reads,
                 conserved_rpm,
                 not_conserved_rpm,
                 percent_coverage_sequence,
                 score,
                 genus)
                 
        OrganismTable.__init__(self,
                               virus_id,
                               virus_name,
                               conserved_reads,
                               not_conserved_reads,
                               conserved_rpm,
                               not_conserved_rpm,
                               percent_coverage_sequence,
                               score,
                               genus)

        def __str__(self):
            return "Virus class"

        
class BacteriaTable(OrganismTable):
    """ Class for bacteria organisms. """

    def __init__(self,
                 bacteria_id,
                 bacteria_name,
                 conserved_reads,
                 not_conserved_reads,
                 conserved_rpm,
                 not_conserved_rpm,
                 percent_coverage_sequence,
                 score,
                 genus):

        OrganismTable.__init__(self,
                               bacteria_id,
                               bacteria_name,
                               conserved_reads,
                               not_conserved_reads,
                               conserved_rpm,
                               not_conserved_rpm,
                               percent_coverage_sequence,
                               score,
                               genus)

        def __str__(self):
            return "Bacteria class"
        

class SummaryTable:

    """ Class of page table = SummaryTable. """
    
    def __init__(self, name, matrix, adnorarn, date, icadn, icarn, vir1, vir2, vir3, bac1, bac2, bac3):
        
        self.name = name
        self.matrix = matrix
        
        self.adnorarn = adnorarn
        self.date = date
        
        self.ic_adn = icadn
        self.ic_arn = icarn
        
        self.vir1 = vir1
        self.vir2 = vir2
        self.vir3 = vir3
        
        self.bac1 = bac1
        self.bac2 = bac2
        self.bac3 = bac3


    def __str__(self):
        return "Page table class"


class InfoTable:

    """ Class of info in table. """
    
    def __init__(self,
                 nb_total_reads,
                 preprocess,
                 classified,
                 human,
                 percent_human,
                 bacteria,
                 percent_bacteria,
                 viruses,
                 percent_viruses):
        
        self.nb_total_reads = nb_total_reads
        self.preprocess = preprocess
        self.classified = classified
        
        self.human = human
        self.percent_human = percent_human
        
        self.bacteria = bacteria
        self.percentbacteria = percentbacteria
        
        self.viruses = viruses
        self.percent_viruses = percent_viruses
        
        self.rpm_ic_adn = 0
        self.rpm_ic_arn = 0
        
        self.raw_ic_adn = 0
        self.raw_ic_arn = 0
        
        self.score_ic_adn = 0
        self.score_ic_arn = 0


    def __str__(str):
        return "Info table class"

    
class GenusTableSum:
    """ Genus table sum class . """

    def __init__(self, genus_name, reads_sample, reads_ntc):
        self.genus_name = genus_name
        self.reads_sample = reads_sample
        self.reads_ntc = reads_ntc


    def __str__(self):
        return "Genus table sum class"


def arguments():
    """ Method that define all arguments ."""

    parser = argparse.ArgumentParser(description="get_list_of_classified_organism.py")

    parser.add_argument("-path_summary",
                        help="(Input) Path of summary file that contain *count.txt file",
                        type=str)
    
    parser.add_argument("-path_report",
                        help="(Input) Path of text report file that contain information about classification with Kraken 2",
                        type=str)
    
    # parser.add_argument("-path_description",
    #                     help="(Input) Path of description file that contain description.txt file",
    #                     type=str)
    
    args = parser.parse_args()

    return args.path_summary, args.path_report
    

if __name__ == "__main__":
        
    sample_list = []

    NTC_identifier = "NEG"
    NTC_name = ""

    PATH_SUMMARY, PATH_REPORT = arguments()

    # If run_description exists cran create a summary html page.
    try:
        summary_array = []
        
        with open(PATH_DESCRIPTION) as summary_file:
            line = summary_file.readline()
            while line:
                
                split = re.split(",", line)
                
                name = split[0]
                
                matrix = split[1]
                
                adnorarn = split[2]
                
                date = split[3]
                
                page_summary_row = SummaryTable(name,
                                                matrix,
                                                adnorarn,
                                                date,
                                                "",
                                                "",
                                                "",
                                                "",
                                                "",
                                                "",
                                                "",
                                                "")
                
                summary_array.append(page_summary_row)
                
                line = summary_file.readline()
    except:
        print("No run_description.txt file found, summary table will lack informations")
        
        # page_summary_row = SummaryTable(name,
        #                              "",
        #                              "",
        #                              "",
        #                              "",
        #                              "",
        #                              "",
        #                              "",
        #                              "",
        #                              "",
        #                              "",
        #                              "")
            
    # summary_array.append(page_summary_row)

    # Open the report of Kraken 2 classifcation.
    try:
        with open(PATH_REPORT) as kraken_2_report:
            line = kraken_2_report.readlines()

            nbtotal = line[0].strip('\n')

            preprocess = line[1].strip('\n')

            classified = line[2].strip('\n')

            human = line[3].strip('\n')

            percenthuman = round(( int(human) / int(preprocess)*100), 2)

            bacteria = line[4].strip('\n')

            percentbacteria = round(( int(bacteria) / int(preprocess)*100), 2)

            viruses = line[5].strip('\n')

            percentviruses = round(( int(viruses) / int(preprocess)*100), 2)

            kraken2_table_report = InfoTable(nbtotal,
                                             preprocess,
                                             classified,
                                             human,
                                             percenthuman,
                                             bacteria,
                                             percentbacteria,
                                             viruses,
                                             percentviruses)
    except:
        print("Error : impossible to open report of Kraken 2 classification.")
        kraken2_table_report = InfoTable("0","0","0","0","0","0","0","0","0")

    # Open count.txt      
    try:
        list_virus_objects = list()

        genus_rank_dict = {}

        with open(PATH_SUMMARY) as summary_file:
            line = summary_file.readline()
            while line:

                split = re.split(",", line)

                id = split[0]

                name = split[1]

                genus = split[6].strip("\n")

                verified = split[2]

                kraken = split[3]

                rpm_verified = round(( int(split[2]) / int(kraken2_table_report.Preprocess) * 1000000), 3)
                rpm_kraken = round(( int(split[3]) / int(kraken2_table_report.Preprocess) * 1000000), 3)
                coverage = float(split[4].strip("\n"))

                score = np.log(rpm_verified*coverage)

                virus_to_add = VirusTable(id,
                                          name,
                                          verified,
                                          kraken,
                                          rpm_verified,
                                          rpm_kraken,
                                          coverage,
                                          score,
                                          "")

                list_virus_objects.append(virus_to_add)

                # Create a dict of genus id.
                if genus in genus_rank_dict:
                    genus_rank_dict[genus] += int(verified)
                else:
                    genus_rank_dict[genus] = int(verified)
                line = summary_file.readline()
    except:
        list_virus_objects = list()
        
    for xa in SampleVirusTable:
        for xb in list_virus_objects:
            if xa.VirusID == xb.VirusID:
                xa.ConservedNTC = xb.ConservedReads
                xa.NotConservedNTC = xb.NotConservedReads
                xa.ConservedNTCRPM = xb.ConservedRPM
                xa.NotConservedNTCRPM = xb.NotConservedRPM
                xa.CoverageNTC = xb.PercentCoverage
                xa.ScoreNTC = xb.Score

    for zb in range(len(SampleVirusTable)):
       if SampleVirusTable[zb].VirusID == "12022":
           SampleInfoTable.RPMIc_Arn = SampleVirusTable[zb].ConservedRPM
           SampleInfoTable.RawIc_Arn = SampleVirusTable[zb].ConservedReads
           SampleInfoTable.ScoreIc_Arn = SampleVirusTable[zb].Score
       if SampleVirusTable[zb].VirusID == "1921008":
           SampleInfoTable.RPMIc_Adn = SampleVirusTable[zb].ConservedRPM
           SampleInfoTable.RawIc_Adn = SampleVirusTable[zb].ConservedReads
           SampleInfoTable.ScoreIc_Adn = SampleVirusTable[zb].Score

    for ya in SampleBacteriaTable:
        for yb in NTCBacteriaTable:
            if ya.BacteriaID == yb.BacteriaID:
                ya.ConservedNTC = yb.ConservedReads
                ya.UniqHitNTC = yb.UniqHit

    file_loader = FileSystemLoader("templates")
    env = Environment(loader=file_loader)
    
    template = env.get_template("datatables_report.html")
    
    output = template.render(sampleName=sampleName,
                             listOfVirusesToShow=SampleVirusTable,
                             listOfBacteriaToShow=SampleBacteriaTable,
                             Table1Fill=SampleInfoTable,
                             GenusTable=GenusTable,
                             GenusTableVir=GenusTableVir)
    
    Page2 = open(os.path.join(inputFolder,sampleName)+"report.html","w")
    Page2.write(output)
    Page2.close()
