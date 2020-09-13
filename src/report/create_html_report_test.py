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
import argparse
import time
import numpy as np
from jinja2 import Environment, FileSystemLoader


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
               

def arguments():
    """ Method that define all arguments ."""

    parser = argparse.ArgumentParser(description="create_html_report.py")

    parser.add_argument("-name_object",
                        help="(Input) Name of the sequences object e.g : 1-MAR-LBA",
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

    return args.name_object, args.path_report, args.path_summary, args.path_template, args.path_output


def get_all_summary_information(path_summary_file):
    """ Function to recover all sumary information from filtered blast classification . Summary file separed element by ',' . """

    list_all_organism = list()

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

                # Print a summary of organism.
                #print(organism)

                # Add object to list.
                list_all_organism.append(organism)

                line = summary_file.readline()

    except FileNotFoundError as err:
        print("Error : {} !".format(err))

    return list_all_organism


def create_output_folder(filename):
    """ Method that create output folder."""

    if not os.path.exists(os.path.dirname(filename)):
        try:
            os.makedirs(os.path.dirname(filename))
        except OSError as exc:
            if exc.errno != errno.EEXIST:
                raise
                
    
def create_html_report(path_output, path_template, name_object, organism_object):
    """ Create a html report. """
    # Folder containt templates.
    file_loader = FileSystemLoader("src/report/templates")
    env = Environment(loader=file_loader)
    
    template = env.get_template("datatables_report_test.html")
    
    # output = template.render(name_object=name_object,
    #                          listOfVirusesToShow=SampleVirusTable,
    #                          listOfBacteriaToShow=SampleBacteriaTable,
    #                          Table1Fill=SampleInfoTable,
    #                          GenusTable=GenusTable,
    #                          GenusTableVir=GenusTableVir)

    output = template.render(name_object=name_object,
                             organism_array=organism_object)    
    
    datatable_report = open(PATH_OUTPUT+name_object+"_report.html","w")
    
    datatable_report.write(output)
    datatable_report.close()

    print("datatable report done !")

    
if __name__ == "__main__":

    print("Create html report")
   
    # Get all arguments.
    NAME_OBJECT, PATH_REPORT, PATH_SUMMARY, TEMPLATE, PATH_OUTPUT = arguments()

    LIST_ORGANISM_OBJECTS = list()
    # Get count.txt (summary.txt) from filtered genus blast classification.
    LIST_ORGANISM_OBJECTS = get_all_summary_information(PATH_SUMMARY)

    # test 
    for organism in LIST_ORGANISM_OBJECTS:
        print("name : {} | number reads : {}".format(organism.name_organism, organism.conserved_reads))

    # Get report.txt file from Kraken 2 classification.

    # Create output folder is doesn't exists.
    create_output_folder(PATH_OUTPUT)

    # Create a html report from datatable template.
    create_html_report(PATH_OUTPUT, TEMPLATE, NAME_OBJECT, LIST_ORGANISM_OBJECTS)
