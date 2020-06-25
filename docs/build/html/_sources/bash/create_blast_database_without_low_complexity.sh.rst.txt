Création d'une base de données pour blast sans les séquences de faibles complexités
===================================================================================

Le programme Shell qui permet de créer une base de données spécifique à l’analyse d'alignement de blast.

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

Création d'une base de données qui peut être utilisée par le logiciel d'alignement de séquences blast avec makeblastdb.

.. warning:
   Le logiciel Dustmasker est utilisé pour supprimer les séquences de faibles complexités au sein de la base de données. 

.. note::
   Les séquences brutes téléchargées avec ncbi ou avec le script python get_database_from_accession_list.py. Le script d'automatise la création d'un seul fichier qui rassemble toutes les séquences au format. fna.

Les paramètres d'entrée
***********************

   * :-path_seqs:

   (Input) Le chemin du dossier contenant toutes les séquences pour permettre la création d'une base de données. \*DIR : all_sequences

   * :-output_fasta: 

   (Output) Le nom du fichier de sortie qui contient toutes les séquences. \*FILE : output_sequences

   * :-name_db:

   (Input/Output) Le nom de la base de données.*DIR: 16S_database

Exemple d'exécution
*******************

.. code-block:: sh

   create_blast_database_without_low_complexity.sh -path_seqs test_database_blast/ -output_fasta output_multi_fasta -name_db database_test

Les fichiers de sorties
***********************

   * Le dossier DUSTMASKER_* va être créé s'il n'est pas encore créé dans la base de données. Ce dossier contient le ficher dustmasker.asnb qui permet d'enlever les séquences à faibles complexités.

   * Le dossier MAKEBLAST_* va créer la base de données.

   * Le fichier README.txt contient un récapitulatif de notre base de données.
