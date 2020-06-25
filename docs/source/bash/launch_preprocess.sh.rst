Lancer le pre-process ou pré-traitement (nettoyage des reads)
=============================================================

Le programme Shell permet de lancer l'action de pré-process ou pré-traitement dans le pipeline. Autrement dit, le script nettoie en supprimant les reads de mauvaises qualités ainsi que les reads en duplicatas.


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
   A besoin des outils comme BBMap (clumpify.sh) et Trimmomatic pour fonctionner.

Les paramètres d'entrés
***********************

   * :-path_reads:

   (Input) Le chemin dossier avec l'ensemble des reads. \*DIR: reads_sample

Exemple d'execution
*******************

.. code-block:: sh

   launch_preprocess.sh -path_reads all_reads_from_sample

Les fichiers de sorties
***********************


