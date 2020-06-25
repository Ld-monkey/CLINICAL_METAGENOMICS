Analyse des séquences ou reads avec l'algorithme de Blast
=========================================================

Le programme Shell permet de réaliser un alignement de séquences avec l'algorithme de blast. Les séquences ou reads sont alignés sur une base de données.

.. warning::
   Il faut créer une base de données spécifique pour l'analyse avec l'algorithme de blast.

.. hint::
   launch_blast_analyse.sh

Localisation
************

.. code-block:: sh

   └── src
    ├── bash
    │   ├── launch_blast_analyse.sh

Description
***********

A partir d'un jeu de séquences ou reads et dépendant de la base de données en argument le script permet de réaliser un alignement de séquence avec l'algorithme de blast.

.. warning:
   Le logiciel blastn est utilisé.

.. note::
   Pour plus d'information sur les paramètres utilisés avec blastn aller sur le lien suivant : http://nebc.nerc.ac.uk/bioinformatics/documentation/blast+/user_manual.pdf

Exemple d'exécution
*******************

.. code-block:: sh

   launch_blast_analyse.sh -path_reads sample_reads -path_db FDA_ARGOS_db -path_result blast_metaplan_output

Les paramètres d'entrés
***********************

  * :-path_reads:

   (Input) Le chemin du dossier avec toutes les séquences ou reads. *DIR: sequences*.fna

  * :-path_db:

  (Input) Le chemin du dossier avec la base de données spécifique à l'algorithme de blast.

  * :-path_results:

  (Output) Le chemin du dossier de sortie pour les résultats. *DIR: blast_result

Les fichiers de sorties
***********************

   * Les fichiers avec l'extension \*.blast.txt résultat de l'algorithme de blast.
