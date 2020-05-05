#coding: utf-8

"""
@author : Zygnematophyce
Mar. 2020
CLINICAL-METAGENOMIC

Program in python to download the NCBITaxa database.

download_ncbi_taxa_db.py {path_of_output_database}
e.g download_ncbi_taxa_db.py ../../data/NCBITaxa/
"""

import sys
from ete3 import NCBITaxa
     
if __name__ == "__main__":
    print("Download NCBI taxonmy database")

    PATH_NCBI_DB=sys.argv[1]

    # Check if INPUT_FOLDER doesn't exist.
    if not os.path.exists(PATH_NCBI_DB):
        os.mkdir(PATH_NCBI_DB)
        print("Folder {} is created".format(PATH_NCBI_DB))

    ncbi = NCBITaxa(dbfile=PATH_NCBI_DB)
    try:
        version = ncbi._NCBITaxa__get_db_version()
    except Exception:
        version = None
