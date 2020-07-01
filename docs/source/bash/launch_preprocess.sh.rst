Lancer le pre-process ou pré-traitement (nettoyage des reads)
=============================================================

L'action de pre-process aussi appelé pré-traitement en méta-génomique permet de nettoyer et de filtrer les reads de mauvaises qualités, qui sont trop petit pour apporter de l'information et qui sont en duplicata exacte.


.. hint::
   remove_poor_quality_duplicate_reads_preprocess.sh

.. code-block:: sh

   └── src
    ├── bash
    │   ├── remove_poor_quality_duplicate_reads_preprocess.sh

Les logiciels utilisés
**********************

   * Le logiciel Clumpify.sh :

   Le script Clumpify.sh de l’aligneur BBMap permet d’identifier les séquences
identiques en sortie de séquençage. Configuré avec le paramètre « Dedupe » le script clumpify, fait intervenir le logiciel Dedupe de la suite BBMap pour éliminer les reads dupliqués.

   * Le logiciel Dedupe :

   Ce logiciel permet de supprimer les reads dupliqués.

   * Le logiciel Trimmomatic :

   Ce logiciel permet de supprimer les reads de mauvaises qualités c'est à dire les reads qui ont un score phread (score de qualité) moyen d'au moins 20 et des reads de taille minimum de 50 nucléotides pour avoir assez d'information pour classifier les reads. 

.. warning::
   L'environnement conda metagenomic_env possède les outils Clumpify.sh, Dedupe (BBMap) et Trimmomatic pour le bon fonctionnement du pipeline.

Les paramètres d'entrée
***********************

   * :-path_reads:

   (Input) Le chemin du dossier avec l'ensemble des reads. \*DIR: reads_sample

   * :-path_outputs:

   (Output) Le chemin du dossier de sortie des reads pré-traités. \*DIR: output_reads_trimmed 

   * :-force_remove:

   (Optional) Par défaut la valeur est sur "yes" et permet de supprimer les fichiers intermédiaires. Pour ne pas supprimer les fichiers intermédiaires configurer le paramètre avec la valeur "no" comme avec l'exemple ci-contre : -force_remove no

Exemple d'exécution
*******************

.. code-block:: sh

   bash src/bash/remove_poor_quality_duplicate_reads_preprocess.sh -path_reads data/reads/PAIRED_SAMPLES_ADN_TEST/ -path_output results/trimmed_reads/trimmed_PAIRED_SAMPLES_ADN_TEST_reads_04_06_2020/

Les fichiers de sorties
***********************

   * <name_of_read>_info.txt :

   Fichier qui contient le nombre de reads total. Prend en compte le nombre de read pour les reads par paire.

   * <name_of_read>_depupe.fastq :

   Résultat des logciels Clumpify.sh et Dedupe pour les reads dupliqués dans notre échantillon qui vont être supprimés.

     
   * <name_of_read>_orphans_unpaired_fastq.gz
   * <name_of_read>_survivors_paired.fastq.gz

   Résultats finals des reads traités par le logiciel Trimmomatic.

   - <name_of_read>_survivors_paired.fastq.gz correspondent donc aux reads qui ont correctement répondu aux conditions de filtrage.
   - <name_of_read>_orphans_unpaired_fastq.gz correspondent aux reads qui n'ont pas correctement répondu aux condition de filtrage.


Perspectives
************

D'autre type de filtrage peuvent être apportée comme la suppression des séquences de faibles complexités dans l'échantillonnage. Le pipeline actuel ne contient pas cette fonctionnalité. 

Ajouter la fonctionnalité de voir la qualité des reads comme avec le logiciel FastQC.
