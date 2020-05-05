.. CLINICAL METAGENOMICS documentation master file, created by
   sphinx-quickstart on Fri Apr 10 18:21:11 2020.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

La documentation : Clinical Metagenomics
========================================

Introduction :
==============

Le but de cette documentation est d'éclaissir les zones d'ombres et de s'imprégner le plus rapidement possible des différents scripts bash et python que constitue ce projet.

Dans cette documentation vous trouvez la description, l'utilisation, les paramètres ou encore les fichiers de sorties de chaques programmes.

.. toctree::
   :maxdepth: 1
   :caption: Shell scripts:
   
   bash/create_kraken_database.sh
   bash/classify_set_sequences.sh
   bash/create_blast_database_without_low_complexity.sh
   bash/launch_blast_analyse.sh
   bash/launch_preprocess.sh
   bash/recover_reads.sh

.. toctree::
   :maxdepth: 1
   :caption: Cluster
      
   cluster/cluster_create_16S_database.sh
   cluster/cluster_create_2_custom_databases_and_classify.sh
   cluster/cluster_launch_blast.sh
   cluster/cluster_launch_preprocess.sh
   cluster/cluster_launch_get_id_and_reads.sh


.. toctree::
   :maxdepth: 1
   :caption: Télécharger les bases de données automatiquement

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
