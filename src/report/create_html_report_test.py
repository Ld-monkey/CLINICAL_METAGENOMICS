#coding: utf-8

"""
@author : Zygnematophyce
July. 2020
CLINICAL METAGENOMICS

python3 src/report/create_html_report_test.py -name_object 1-MAR-LBA -path_report results/30_08_2020_20h_56m_49s/kraken2_classification/1-MAR-LBA-ADN_S1/1-MAR-LBA-ADN_S1_taxon.report.txt -path_summary results/30_08_2020_20h_56m_49s/same_taxonomics_id_kraken_blast/summary.txt -path_template src/report/templates/datatables_report_test.html -path_output results/30_08_2020_20h_56m_49s/all_reports/


(old name : run.py)
"""


import re
import os
import math
import sys
import warnings
import argparse
import time
import numpy as np
from jinja2 import Environment, FileSystemLoader
from ete3 import NCBITaxa


# Init ete3 NCBITaxa package.
ncbi = NCBITaxa()


class OrganismTable:
    """ Super class for all organisms. """

    # Miss percent_coverage_sequence.
    def __init__(self,
                 taxonomic_id,
                 name_organism,
                 conserved_reads,
                 not_conserved_reads,
                 conserved_rpm,
                 not_conserved_rpm,
                 score,
                 genus):
        
        self.taxonomic_id = taxonomic_id
        self.name_organism = name_organism

        self.conserved_reads = conserved_reads
        self.not_conserved_reads = not_conserved_reads

        self.conserved_rpm = conserved_rpm
        self.not_conserved_rpm = not_conserved_rpm

        self.conserved_NTC = 0
        self.not_conserved_NTC = 0
        self.score_NTC = 0

        self.conserved_CRPM = 0
        self.not_conserved_CRPM = 0

        self.corevage_NTC = 0

        self.score = score

        self.genus = genus

        
    def __str__(self):
        return "-- Organism class -- \n"\
            "Taxonomic Id : {} \n" \
            "Name organism : {} \n" \
            "Conserved reads : {} \n"\
            "Not conserved reads : {} \n" \
            "Conserved rpm : {} \n" \
            "Not conserved rpm : {} \n" \
            "Score : {} \n" \
            "Genus : {}" \
            "-------------------".format(self.taxonomic_id,
                                         self.name_organism,
                                         self.conserved_reads,
                                         self.not_conserved_reads,
                                         self.conserved_rpm,
                                         self.not_conserved_rpm,
                                         self.score,
                                         self.genus)


class PreviewInformation:
    """
    Some preview information as total number of reads. E.g get number of reads before 
    and after the preprocess and report.txt file from Kraken 2 classification.
    """

    def __init__(self, path_info_before_preprocess, path_info_after_preprocess, path_kraken_report):
        
        self.total_reads_before = self.__count_total_reads(path_info_before_preprocess)
        self.total_reads_after = self.__count_total_reads(path_info_after_preprocess)

        # Private list of all report kraken2 informations.
        self.__all_kraken_report_information = self.__count_classified_kraken(path_kraken_report)

        self.percent_kraken_unclassication = self.__all_kraken_report_information[0]
        self.percent_kraken_classification = self.__all_kraken_report_information[1]
        self.total_kraken_classified = self.__all_kraken_report_information[2]

        
    def __count_total_reads(self, path_file):
        """ Private function to return the total of read stored in file. """
        try:
            with open(path_file) as file_preprocess:
                total_reads = int(file_preprocess.readline())
        except FileNotFoundError as er:
            print("Error : {}".format(er))
            total_reads = 0

        return total_reads
    

    def __count_classified_kraken(self, path_file):
        """ Private function to return the total of classified by Kraken 2. """
        try:
            with open(path_file) as kraken_file:
                report_line = kraken_file.readline().strip()
                while report_line:
                    split_report = report_line.split("\t")

                    if split_report[3] == "U":
                        print(report_line)
                        total_percentage_unclassified = float(split_report[0])
                        print("total % unclassified : {} %".format(total_percentage_unclassified))
                        
                    if split_report[3] == "R":
                        print(report_line)
                        total_percentage_classified = float(split_report[0])
                        print("total % classified : {} %".format(total_percentage_classified))

                        total_classified_reads = int(split_report[1])
                        print("total classified reads :", total_classified_reads)

                    report_line = kraken_file.readline()
        except FileNotFoundError as er:
            print("Error : {}".format(er))
            total_percentage_unclassified = 0
            total_percentage_classified = 0
            total_classified_reads = 0

        return [total_percentage_unclassified, total_percentage_classified, total_classified_reads]
                    
               
def arguments():
    """ Method that define all arguments ."""

    parser = argparse.ArgumentParser(description="create_html_report.py")

    parser.add_argument("-name_object",
                        help="(Input) Name of the sequences object e.g : 1-MAR-LBA",
                        type=str)

    parser.add_argument("-before_preprocess",
                        help="(Input) Path of file with the total of reads before preprocess",
                        type=str)

    parser.add_argument("-after_preprocess",
                        help="(Input) Path of file with the total of reads after preprocess",
                        type=str)

    parser.add_argument("-path_report",
                        help="(Input) Path of text report file that contain information about classification with Kraken 2",
                        type=str)

    parser.add_argument("-path_summary",
                        help="(Input) Path of summary file that contain *countbis.txt file",
                        type=str)

    parser.add_argument("-path_template",
                        help="(Input) Path of template file for html report",
                        type=str)
    
    parser.add_argument("-path_output",
                        help="(Output) Path output folder",
                        type=str)
    
    args = parser.parse_args()

    return args.name_object, args.before_preprocess, args.after_preprocess, args.path_report, args.path_summary, args.path_template, args.path_output


def create_organism_object(path_summary_file):
    """ Function to recover all sumary information from filtered blast classification . Summary file separed element by ',' . """

    # Dictonnary of all superkingdom and their organism.
    dict_superkingdom = dict()

    # List of all superkingdom (e.g : Bacteria, Virus ...)
    list_superkingdom = list()

    try:
        with open(path_summary_file) as summary_file:
            line = summary_file.readline()

            while line:
                split_information = re.split(",", line)
                
                taxonomic_id = split_information[0]
                organism_name = split_information[1]
                
                conserved_reads = split_information[2]
                not_conserved_reads = split_information[3]

                sequencing_coverage = float(split_information[4])
                genus_name = split_information[6]

                reads_per_million = round((int(conserved_reads) / int(1)*1000000), 3)
                rpm_kraken = round((int(not_conserved_reads) / int(1)*1000000), 3)

                score = np.log(reads_per_million*sequencing_coverage)

                # Create a organism object.
                organism = OrganismTable(
                    taxonomic_id,
                    organism_name,
                    conserved_reads,
                    not_conserved_reads,
                    reads_per_million,
                    rpm_kraken,
                    score,
                    genus_name)
                
                # Get ncbi superkingdom status from ete3 package. 
                for rank in ncbi.get_lineage(taxonomic_id):
                    if ncbi.get_rank([rank]).get(rank) == "superkingdom":

                        # Get the name of super kingdom (e.g Bacteria, Virus, Eukaryota).
                        ncbi_superkingdom = ncbi.get_taxid_translator([rank]).get(rank)

                        # If super kingdom is eukaryota search kingdom (e.g Fungi).
                        if ncbi_superkingdom == "Eukaryota":
                            for rank in ncbi.get_lineage(taxonomic_id):
                                if ncbi.get_rank([rank]).get(rank) == "kingdom":
                                    
                                    # Get the name of kingdom (e.g Fungi ...).
                                    ncbi_kingdom = ncbi.get_taxid_translator([rank]).get(rank)

                                    ncbi_superkingdom = ncbi_superkingdom+"-"+ncbi_kingdom                                                            

                        # Check if superkingdom is not in list.
                        if ncbi_superkingdom not in list_superkingdom:

                            # Add a superkingdom.
                            list_superkingdom.append(ncbi_superkingdom)

                            # Create a key with a list of value.
                            dict_superkingdom[str(ncbi_superkingdom)] = []

                        # Add the organism object in correct key of dictonnary.
                        dict_superkingdom[str(ncbi_superkingdom)].append(organism)

                line = summary_file.readline()

    except FileNotFoundError as err:
        print("Error : {} !".format(err))
        
    return dict_superkingdom


def create_output_folder(filename):
    """ Method that create output folder."""

    if not os.path.exists(os.path.dirname(filename)):
        try:
            os.makedirs(os.path.dirname(filename))
        except OSError as exc:
            if exc.errno != errno.EEXIST:
                raise
                
    
def create_html_report(path_output, path_template, name_object, organism_object, preview_object):
    """ Create a report thank html template. """
    
    # Folder containt template.
    path_folder_template = os.path.dirname(path_template)

    # Basename of template.
    basename_template = os.path.basename(path_template)

    # According with jinja2 modele with ./templates folder.
    loader_template = FileSystemLoader(path_folder_template)
    env = Environment(loader=loader_template)
    
    template = env.get_template(basename_template)
    
    # output = template.render(name_object=name_object,
    #                          listOfVirusesToShow=SampleVirusTable,
    #                          listOfBacteriaToShow=SampleBacteriaTable,
    #                          Table1Fill=SampleInfoTable,
    #                          GenusTable=GenusTable,
    #                          GenusTableVir=GenusTableVir)

    output = template.render(name_object=name_object,
                             organism_array=organism_object,
                             preview_information=preview_object)    
    
    datatable_report = open(PATH_OUTPUT+name_object+"_report.html","w")
    
    datatable_report.write(output)
    datatable_report.close()

    print("Datatable report done !")

    
if __name__ == "__main__":

    print("Report creation")
   
    # Get all arguments.
    NAME_OBJECT, BEFORE_PREPROCESS, AFTER_PREPROCESS, PATH_REPORT, PATH_SUMMARY, TEMPLATE, PATH_OUTPUT = arguments()

    # Store organism object in dictonnary.
    DICT_ORGANISMS_OBJECTS = dict()
    
    # Get count.txt (summary.txt) from filtered genus blast classification.
    DICT_ORGANISMS_OBJECTS = create_organism_object(PATH_SUMMARY)

    # Create a PreviewInformation object.
    preview_information = PreviewInformation(BEFORE_PREPROCESS,
                                             AFTER_PREPROCESS,
                                             PATH_REPORT)

    # Create output folder is doesn't exists.
    create_output_folder(PATH_OUTPUT)

    # Create a html report from datatable template.
    create_html_report(PATH_OUTPUT, TEMPLATE, NAME_OBJECT, DICT_ORGANISMS_OBJECTS, preview_information)
