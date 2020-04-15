Création de plusieurs bases de données et classification
========================================================

Le programme destiné au cluster pour créer plusieurs bases de données est :

.. hint::
   cluster_create_2_custom_databases_and_classify.sh

Localisation
************

.. code-block:: sh


   └── src
    ├── cluster
    │   └── cluster_create_2_custom_databases_and_classify.sh

Description
***********

Automatise la création de plusieurs bases de données différentes et execute la classification de reads.

Les bases de données créées dans ce script sont les suivantes :

   * FDA-ARGOS database
   * FDA-ARGOS + RefSeqHuman + Virus database

La classification des reads se fait sur les bases de données suivantes :

   * FDA-ARGOS,
   * FDA database + RefSeqHuman + Virus,
   * RefSeq,
   * FDA-ARGOS avec prepocess et dust,
   * FDA-ARGOS + RefSeqHuman + Virus preprocess.

Pour comprendre les scripts du preprocess et de dust aller à la rebrique suivante : .

.. warning::
   La variable PATH est incompatible avec d'autre environnement. Trouver un moyen avec un environnement conda.

.. note::
   Le module kraken 2 doit être chargé.

.. note::
   L'extention des échantillons sont transformés automatiquement en format .fastq .

Les paramètres d'entrés
***********************

.. note::
   Aucun

Le fichier de sortie
********************

Le programme sort les fichiers des bases de données créées et les classifications sur l'échantillon pour chaque bases de données.
