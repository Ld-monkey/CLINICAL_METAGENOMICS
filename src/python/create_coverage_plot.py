#coding: utf-8

"""
@author : Zygnematophyce
July. 2020
CLINICAL METAGENOMICS

e.g : 
python3 src/python/create_depth_plots.py 
-path_counter results/30_08_2020_20h_56m_49s/same_taxonomics_id_kraken_blast/countbis.txt 
-path_conserved results/30_08_2020_20h_56m_49s/same_taxonomics_id_kraken_blast/conserved_sorted.txt 
-path_plot results/30_08_2020_20h_56m_49s/all_plots/

(old name : create_depth_plot.py)
"""


import matplotlib.pyplot as plt
import numpy as np
import argparse
import math
import re
import os
import sys
from ete3 import NCBITaxa


# Create a instance of ete3.
ncbi = NCBITaxa()


def arguments():
    """ Method that define all arguments ."""

    parser = argparse.ArgumentParser(description="get_list_of_classified_organism.py")

    parser.add_argument("-path_counter",
                        help="(Input) File text with all count",
                        type=str)

    parser.add_argument("-path_conserved",
                        help="(Input) File text with all count",
                        type=str)
    
    parser.add_argument("-path_plot",
                        help="(Output) Path of plots folder",
                        type=str)
    
    args = parser.parse_args()

    return args.path_counter, args.path_conserved, args.path_plot


def create_output_graph_folder(path_output, list_information):
    """ Creates graph folder if it doesn't exist. """

    for taxonomic_id in list_information:
        name_folder = taxonomic_id.split(",")[0]
        if not os.path.exists(path_output+str(name_folder)):
            try:
                os.makedirs(path_output+str(name_folder))
            except OSError as exc:
                if exc.errno != errno.EEXIST:
                    raise
                

def get_all_name_of_species(path_count_file):
    """ For each taxonID, gets corresponding name of species 
    + Creates first part of the output. """

    line_to_copy = list()

    try:
        with open(path_count_file) as cout_file:
            dict_list_species = dict()
            line = cout_file.readline()
            
            while line:
                split_line = re.split(" ", line)
                print("split_line : ", split_line)

                taxonomic_id = split_line[0].strip("\n")
                print("taxonomic ID : ", taxonomic_id)

                count_reads = split_line[1] + "," + split_line[2].strip('\n')
                print("count reads : ", count_reads)

                taxonomic_id_name_dict = ncbi.get_taxid_translator([taxonomic_id])
                print("ID + Name : ", taxonomic_id_name_dict)

                # Adds key:value elements to the dictionary.
                dict_list_species.update(taxonomic_id_name_dict)

                taxonomic_name = taxonomic_id_name_dict[list(taxonomic_id_name_dict.keys())[0]]
                print("taxonomic name: ", taxonomic_name)

                taxonomic_name = taxonomic_name.replace("/", "_")
                print("taxonomic name replace : ", taxonomic_name)

                line_to_copy.append(taxonomic_id+","+taxonomic_name+","+count_reads)
                
                line = cout_file.readline()
                print("line to copy :", line_to_copy)                
    except FileNotFoundError as e:
        sys.exit("Error: {}".format(e))

    return line_to_copy, dict_list_species


def list_of_size_n(n):
    """ """
    cover = [0]*(n+1)
    print("In list_of_size_n len(cover) :", len(cover))
    return cover


def open_conserved_file(path_conserved, dict_list_species, path_output):
    """ For each specie, create a list of all coordinates of alignment, 
    and draw the plot based on this list. """

    dict_list_coverage = dict()
    dict_list_size_genome = dict()
    dict_list_genus = dict()

    print("-----------------------------")
    
    try:
        # Open ***.conserved.txt
        with open(path_conserved) as conserved_file:

            line = conserved_file.readline()
            
            while line:
                
                split_line = re.split(r'\t', line)
                print(split_line)

                # Get staxids = means unique Subject Taxonomy ID(s)
                # in blast result.
                blast_staxids = split_line[7].strip('\n')
                print("taxnomic id :", blast_staxids)
                
                lineage = ncbi.get_lineage(blast_staxids)
                print("lineage :", lineage)
                
                ranks = ncbi.get_rank(lineage)
                print("ranks :", ranks)
                
                genus = -1
                
                for k in ranks:
                    if ranks[k] == 'genus':
                        genus = k

                # Same blast_staxids WARNING.
                species_tick = split_line[7].strip('\n')
                print("species tick:", species_tick)

                # Get slen = subject sequence length in blast
                # result.
                blast_sequence_length = int(split_line[6])
                print("blast_sequence_length :", blast_sequence_length)
                
                cover_list = list()

                # List of set size filled with 0
                cover_list = list_of_size_n(blast_sequence_length)

                print("len(cover_list) :", len(cover_list))

                coord_start = list()
                
                coord_end = list()

                # For each read of the same specie, memorize
                # the coordinates of alignment.

                # roughly, as long as the taxonomic id doesn't change.
                # LEGACY CODE.
                while blast_staxids == species_tick:
                    print("split_line :", split_line)

                    # Get sstart = start of alignment in subject
                    # in blast result.(see classify_set_reads_blast.sh)
                    coord_start.append(min(int(split_line[2]),
                                           int(split_line[3])))

                    #print("coord_start :", coord_start)

                    # Get send = end of alignment in subject
                    # in blast result.(see classify_set_reads_blast.sh)
                    coord_end.append(max(int(split_line[2]),
                                         int(split_line[3])))

                    #print("coord_end :", coord_end)
                    
                    line = conserved_file.readline()
                    print("line in 2nd while :", line)
                    
                    split_line = re.split(r'\t',line)
                    print("split_line in 2nd while :", split_line)

                    # Exception when staxids in blast does not exists.
                    try:
                        species_tick = split_line[7].strip('\n')
                        print("species_tick in 2nd while :", split_line)
                    except:
                        species_tick = -1

                # List of 0 is being incremented according to previously
                # memorized coordinate.
                for j in range(len(coord_start)): 
                    for i in range (coord_start[j], coord_end[j]+1):
                        try:
                            cover_list[i] += 1
                        except:
                            print("A bad allocation")
                            #print(sampleID)
                            #print(species)
                            print(str(range(len(coord_start))))
                            print(str(coord_start[j])+' - '+str(coord_end[j]+1))

                coverage_percent = str(round(((len(cover_list)-cover_list.count(0))/len(cover_list)*100),5))

                #
                dict_list_coverage.update({blast_staxids: coverage_percent})

                #
                dict_list_size_genome.update({blast_staxids: str(blast_sequence_length)})

                #
                if genus != -1:
                    taxid2name = ncbi.get_taxid_translator([genus])[genus]
                    dict_list_genus.update({blast_staxids: taxid2name})
                else:
                    dict_list_genus.update({blast_staxids: "Unknown Genus"})

                # Draw the depth/coverage plot following the list.
                if len(coord_start)>=5:
                    
                    x = np.arange(len(cover_list))

                    plt.plot(x, cover_list, color="#2d6a9f")
                    plt.fill_between(x, 0 ,cover_list, facecolor="#609dd2")
                    plt.xlim(left=0.0, right=len(cover_list))
                    plt.ylim(bottom=0.0)
                    plt.ylabel("Depth")

                    # WARNING : pass variable.
                    species_name = dict_list_species[int(blast_staxids)]
                    species_name = species_name.replace("/", "_")

                    if genus != -1:
                        
                        plt.xlabel(species_name+" (genus:"+taxid2name+")")
                        
                        # Save figure.
                        plt.savefig(path_output+species_name+".png",
                                    bbox_inches="tight")

                        print("create {}{}.png".format(path_output,
                                                       species_name))
                    else:
                        plt.xlabel(species_name)

                        # Save figure.
                        plt.savefig(path_output+species_name+".png",
                                    bbox_inches="tight")

                        print("create {}{}.png".format(path_output,
                                                       species_name))
                    plt.clf()

    except FileNotFoundError as e:
        sys.exit("Error: {}".format(e))

                

if __name__ == "__main__":
    print("Create all plots")

    COUNT_FILE, PATH_CONSERVED, PATH_PLOTS = arguments()

    # list of all parameters.
    list_information = list()

    dict_species = dict()

    #
    list_information, dict_species = get_all_name_of_species(COUNT_FILE)

    # Create graph folder.
    create_output_graph_folder(PATH_PLOTS, list_information)
    
    # Open conserved file.
    open_conserved_file(PATH_CONSERVED, dict_species, PATH_PLOTS)
