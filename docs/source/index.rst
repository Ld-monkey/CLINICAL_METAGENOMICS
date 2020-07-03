.. CLINICAL METAGENOMICS documentation master file, created by
   sphinx-quickstart on Fri Apr 10 18:21:11 2020.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Documentation
=============

Introduction :
==============

Le but de cette documentation est d’éclaircir les zones d'ombres du projet de métagénomique clinique « CLINICAL_METAGENOMICS » et de s'imprégner le plus rapidement possible des différents scripts Bash et python que constitue ce projet.

Dans cette documentation vous trouvez la description, l'utilisation, les paramètres ou encore les fichiers de sorties de chaque programme.

.. toctree::
   :maxdepth: 1
   :caption: Shell scripts:
   
   bash/create_kraken_database.sh
   bash/classify_set_sequences.sh
   bash/create_blast_database_without_low_complexity.sh
   bash/launch_blast_analyse.sh
   bash/launch_preprocess.sh
   bash/recover_reads.sh
   bash/find_same_id_kraken_blast_bacteria.sh

.. toctree::
   :maxdepth: 1
   :caption: Python scripts:

   python/sort_blasted_seq.py

.. toctree::
   :maxdepth: 1
   :caption: Télécharger les bases de données automatiquement

   download/download_ncbi_kraken2_taxonomy.sh
   download/download_refseq_species_sequences.sh
   download/download_ete3_ncbi_taxonomy_database.sh

.. toctree::
   :maxdepth: 1
   :caption: Environnement Conda

   conda/conda_environnement

.. toctree::
   :maxdepth: 1
   :caption: SnakeMake
   

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
