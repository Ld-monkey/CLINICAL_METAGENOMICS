Création d'un base de donnée 16S avec le cluster
================================================

Le programme destiné au cluster pour créer un base de donnée 16S est :

.. hint::
   cluster_create_16S_database.sh

Localisation
************

.. code-block::

   └── src
    ├── cluster
    │   └── cluster_create_16S_database.sh

Description
***********

Automatise la création d'une base de donnée 16S sur un cluster. Il récupère toutes les séquences et les stocke dans le format .fastq .

.. note::
   Le script ne fait que appeler le programme python get_database_from_accession_list.py. L'avantage du script shell est qu'il est adapté à l'utilisation dans un cluster. Pour plus d'information sur le programme python voir https://github.com/Zygnematophyce/FASTQ_FROM_ACCESSION_LIST .

.. warning::
   Utilise un environnement conda.

Les paramètres d'entrés
***********************

   * :ACCESSION_LIST_FILE:

   (Input) Le chemin du fichier de la liste d'accession (.seq)

   * :NAME_OUTPUT_FASTQ:

   (Output) Le nom du fichier de sortie en format .fastq .

.. code-block:: sh

   qsub cluster_create_16S_database.sh accession_list_16S_ncbi.seq 16S_output_database.fastq

Le fichier de sortie
********************

Le programme sort l'ensemble des séquences d'intérets dans le format .fastq.
