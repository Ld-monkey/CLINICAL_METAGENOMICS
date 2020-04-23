Lancer le préprocess ou nettoyage des séquences ou reads
========================================================

Le programme shell permet de lancer l'action de preprocess dans le pipeline. Autrement dit le script nettoye en supprimant les reads ou séquences de mauvaises qualités ainsi que les reads en duplicatas.


.. hint::
   launch_preprocess.sh

.. code-block:: sh

   └── src
    ├── bash
    │   ├── launch_preprocess.sh

Description
***********

Le script nettoie en supprimant les duplicatas et la mauvaise qualité des reads.

.. warning::
   A besoin des outils comme BBMap (clumpify.sh) et  Trimmomatic pour fonctionner.

Les paramètres d'entrés
***********************

   * :-path_reads:

   (Input)  Le chemin dossier avec l'ensemble des reads. \*DIR: reads_sample

Exemple d'execution
*******************

.. code-block:: sh

   launch_preprocess.sh -path_reads all_reads_from_sample

Les fichiers de sorties
***********************


