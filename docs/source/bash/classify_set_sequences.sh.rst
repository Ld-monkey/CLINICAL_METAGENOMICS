Classifier les reads
====================

Le programme Shell qui permet la classification des reads s'appelle :

.. hint::
   classify_set_reads_kraken.sh

Le programme utilise l'algorithme des k-mers du logiciel Kraken 2 pour classifier plus rapidement les reads.

Localisation
************

.. code-block:: sh

   └── src
    ├── bash
    │   ├── classify_set_reads_kraken.sh

Description
***********

Classifie les organismes présents dans un échantillon de reads. L'échantillon de reads doit posséder la totalité des séquences en nucléotides en format fastq. Normalement, une étape de pré-traitement (pre-processing) est appliqué sur les reads en amont de cette étape de classification (voir :ref:`launch_preprocess.sh`).

.. warning::
   Les séquences par paires doivent s'appeler \*R1\*.fastq

Les paramètres d'entrée
***********************

   * :-path_reads:

   (Input) Le chemin du dossier l'échantillon contenant les reads.                 \*FILE: sequences.fastq

   * :-path_db:

   (Input)  Le chemin du dossier qui contient la base de donnée.
   \*DIR: input_database avec hash.k2d + opts.k2d + taxo.k2d.

   * :-path_output:

   (Output) Le nom du dossier de sortie.                                            \*DIR: output_database
   
   * :-threads:

   (Input) Le nombre de threads utilisé pour classifier les reads. Par défaut le nombre de threads est 8.                \*INT: e.g 9

Exemple exécution
*******************

.. code-block:: sh

   bash src/bash/classify_set_reads_kraken.sh \
                -path_reads results/trimmed_reads/trimmed_PAIRED_SAMPLES_ADN_TEST_reads_01_07_2020/ \
                -path_db data/databases/kraken_2/fda_argos_with_none_library_kraken_database_07_06_2020/ \
                -path_output results/classify_reads/trimmed_classify_fda_argos_with_none_library_02_07_2020/ \
                -threads 8


Les fichiers de sorties
***********************

Les fichiers de sorties sont les suivants : \*.clseqs\_\*.fastq, \*.unclseq_*.fq, \*.output.txt, \*.report.txt .

   * \*.clseqs.fastq : Tous les reads classés.
   * \*.unclseqs.fastq : Tous les reads non-classés.
   * \*.output.txt : ?.
   * \*.report.txt : La phylogénie des organismes qui sont classés avec succès.
   
