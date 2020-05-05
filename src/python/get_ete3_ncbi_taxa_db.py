#coding: utf-8

"""
@author : Zygnematophyce
Mar. 2020
CLINICAL-METAGENOMIC

Program in python to download the NCBITaxa database.
e.g python get_ete3_ncbi_taxa_db.py
"""

from ete3 import NCBITaxa

if __name__ == "__main__":
    print("Download NCBI taxonmy database")

    ncbi = NCBITaxa()
    try:
        version = ncbi._NCBITaxa__get_db_version()
    except Exception:
        version = None
