Classifier les séquences
========================

Le programme Shell qui permet d'exécuter la classification d'organismes s'appelle :

.. hint::
   classify_set_sequences.sh

Localisation
************

.. code-block:: sh

   └── src
    ├── bash
    │   ├── classify_set_sequences.sh

Description
***********

Détermine les organismes présents dans un échantillon ou reads. L'échantillon possède la totalité des séquences nucléotidique avec un format fastq.

.. warning::
   Les séquences par paires doivent s'appeler \*R1\*.fastq

.. note::
   \* L'étoile indique que n'importe quelle chaine de caractère peut se positionner avant ou après.

Les paramètres d'entrés
***********************

   * :-path_reads:

   (Input) Le chemin du dossier l'échantillon contenant les reads.                 \*FILE: sequences.fastq

   * :-path_db:

   (Input)  Le chemin du dossier qui contient la base de donnée.
   \*DIR: input_database avec hash.k2d + opts.k2d + taxo.k2d.

   * :-path_output:

   (Output) Le nom du dossier de sortie.                                            \*DIR: output_database
   
   * :-threads:

   (Input) Le nombre de puissance (threads) pour classer plus vite.                \*INT: e.g 1

Example execution
*******************

.. code-block:: sh

   classify_set_sequences.sh -path_reads all_reads_from_sample -path_db database_FDA_ARGOS -path_output output_result -threads 1

Les fichiers de sorties
***********************

Les fichiers de sorties sont les suivants : \*.clseqs\_\*.fastq, \*.unclseq_*.fq, \*.output.txt, \*.report.txt .

   * \*.clseqs.fastq : Tous les reads classés.
   * \*.unclseqs.fastq : Tous les reads non-classés.
   * \*.output.txt : ?.
   * \*.report.txt : La phylogénie des organismes qui sont classés avec succès.
   
