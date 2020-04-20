Création d'une base de donnée pour blast sans les séquences a faibles complixitées
==================================================================================

Le programme shell qui permet de créer un base de donnée spécific au analyse d'alignement de blast.

.. hint::
   create_blast_database_without_low_complexity.sh

Localisation
************

.. code-block:: sh

   └── src
    ├── bash
    │   ├── create_blast_database_without_low_complexity.sh

Description
***********

Création d'une base de donné qui peut être utilisée par le logiciel d'alignement de séquences blast avec makeblastdb.

.. warning:
   Le logiciel dustmasker est utilisé pour supprimer les séquences de faibles complexitées au sein de la base de donnée. 

.. note::
   Les séquences brutes téléchargées avec ncbi ou avec le script python get_database_from_accession_list.py. Le script d'automatise la création d'un seul fichier qui rassemble toutes les séquences au format .fna .

Les paramètres d'entrés
***********************

   * :-path_seqs:

   (Input)  The path of all sequences to create database.*DIR: all_sequences

   * :-output_fasta:

   (Output) The output file containt all sequences.*FILE: output_sequences

   * :-name_db:

    (Input/Output)  The name of database.*DIR: 16S_database

Exemple d'execution
*******************

.. code-block:: sh
   create_blast_database_without_low_complexity.sh -path_seqs test_database_blast/ -output_fasta output_multi_fasta -name_db database_test

Les fichiers de sorties
***********************

   * Le dossier DUSTMASKER_* va être créé s'il n'est pas encore créé dans la base de donnée. Ce dossier contient le ficher dustmasker.asnb qui permet d'enlever les séquences à faibles complexitées.

   * Le dossier MAKEBLAST_* va créer la base de donnée

   * Le fichier README.txt contient un récapitulatif de notre base de donnée.
