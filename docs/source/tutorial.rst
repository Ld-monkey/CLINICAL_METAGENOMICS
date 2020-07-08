Tutoriel
########

Ci-dessous vous pouvez trouver le tutoriel sur comment utiliser le pipeline de métagénomique clinique.

.. contents::
   :depth: 2

.. _pre_processing:

Le pré-traitement des reads
---------------------------

L'exemple suivant nous montre comment utiliser les étapes de pré-traitement.

Programme
~~~~~~~~~

Nom du programme::

   remove_poor_quality_duplicate_reads_preprocess.sh

Localisation
~~~~~~~~~~~~

.. code-block:: sh

   └── src
    ├── bash
    │   ├── remove_poor_quality_duplicate_reads_preprocess.sh

Les outils utilisés
~~~~~~~~~~~~~~~~~~~

:Clumpify.sh: Le script Clumpify.sh de l’aligneur BBMap permet d’identifier les séquences identiques en sortie de séquençage. Configuré avec le paramètre Dedupe le script clumpify, fait intervenir le logiciel Dedupe de la suite BBMap pour éliminer les reads dupliqués.

:Dedupe: Dedupe supprime les reads dupliqués.

:Trimmomatic: Trimmomatic permet de supprimer les reads de mauvaises qualités c'est à dire les reads qui ont un score phread (score de qualité) moyen d'au moins 20 et des reads de taille minimum de 50 nucléotides pour avoir assez d'information pour classifier les reads.

Exemple d'utilisation
~~~~~~~~~~~~~~~~~~~~~


.. code-block:: sh

   bash src/bash/remove_poor_quality_duplicate_reads_preprocess.sh \
                -path_reads data/reads/PAIRED_SAMPLES_ADN_TEST/ \
                -path_output results/trimmed_reads/trimmed_PAIRED_SAMPLES_ADN_TEST_reads_04_06_2020/ \
                -threads 28

Dans cet exemple, nous indiquons le dossier contenant les reads et nous précisons le dossier de sortie pour lequel les reads sortirons traités et filtrés. Nous pouvons préciser le nombre de threads pour accélérer le traitement, ici le nombre de thread est à 28.

Les paramètres
~~~~~~~~~~~~~~

:-path_reads: (Input) Le chemin du dossier avec l'ensemble des reads.

:-path_outputs: (Output) Le chemin du dossier de sortie des reads pré-traités. 

:-threads: (Input) Le nombre de thread (par défaut configuré à 1 thread).

:-force_remove: (Optionnel) Par défaut la valeur est sur "yes" et permet de supprimer les fichiers intermédiaires. Pour ne pas supprimer les fichiers intermédiaires configurer le paramètre avec la valeur "no" comme avec l'exemple ci-contre :

.. code-block:: sh

   bash src/bash/remove_poor_quality_duplicate_reads_preprocess.sh \
                -path_reads data/reads/PAIRED_SAMPLES_ADN_TEST/ \
                -path_output results/trimmed_reads/trimmed_PAIRED_SAMPLES_ADN_TEST_reads_04_06_2020/ \
                -force_remove no \
                -threads 28

LES fichiers de sorties
~~~~~~~~~~~~~~~~~~~~~~~

   * Avec l'outil Trimmomatic :

::

   <name_of_read>_trimmed.fastq.gz  

**<name_of_read>_trimmed.fastq.gz** correspondent aux reads qui ont correctement répondu aux conditions de filtrage.

::

   <name_of_read>_unpair_trimmed_fastq.

**<name_of_read>_unpair_trimmed_fastq.gz** correspondent aux reads qui n'ont pas correctement répondu aux conditions de filtrage.

   * Avec l'outil Clumpify.sh et Dedupe:

::

   <name_of_read>_depupe.fastq :

**<name_of_read>_depupe.fastq** est le résultat des outils Clumpify.sh et Dedupe pour les reads.

::

   <name_of_read>_info.txt

**<name_of_read>_info.txt** contient le nombre de reads totaux.


.. _download_FDA_ARGOS:

Le téléchargement de la base de données FDA-ARGOS
-------------------------------------------------

La session suivante, nous montre comment télécharger la base de données FDA-ARGOS.

Programme
~~~~~~~~~

Nom du programme::

   download_fda_argos_assembly.sh

Localisation
~~~~~~~~~~~~

.. code-block:: sh

   └── src
    ├── download
    │   ├── download_fda_argos_assembly.sh


Exemple d'utilisation
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: sh

   bash src/download/download_fda_argos_assembly.sh \
                    -assembly_xml data/assembly/assembly_fda_argos_ncbi_result.xml \
                    -path_output data/raw_sequences/fda_argos_assembly_raw_sequences/

Dans cet exemple, nous téléchargeons les séquences assemblées de FDA-ARGOS à l'aide d'un fichier XML présent dans le dossier data/assembly/assembly_fda_argos_ncbi_result.xml de l'architecture du projet git et nous précisons le dossier de sortie qui contiendra toutes les séquences, ici nous voulons que les résultats se retrouvent dans le dossier data/raw_sequences/fda_argos_assembly_raw_sequences/ .

.. note::
   Il serait intéressant d'ajouter une fonctionnalité au programme afin de télécharger le fichier XML automatiquement avec les requêtes de NCBI et ainsi avoir les dernières modifications et ajouts de la base de données FDA-ARGOS.

Les paramètres
~~~~~~~~~~~~~~

:-assembly_xml: (Input) Récupère le fichier XML pour l'analyser.

:-path_output: (Output) Le chemin du dossier de sortie des les séquences de FDA-ARGOS. 

Les fichiers de sorties
~~~~~~~~~~~~~~~~~~~~~~~

L'ensemble des séquences assemblées de FDA-ARGOS vont être téléchargées exemple :

.. code-block:: sh

   ├── GCF_000626615.2_ASM62661v3_genomic.fna
   ├── GCF_000783435.2_ASM78343v2_genomic.fna
   ├── GCF_000783445.2_ASM78344v2_genomic.fna
   ├── GCF_000783455.2_ASM78345v2_genomic.fna
   ├── GCF_000783465.2_ASM78346v2_genomic.fna
   ├── ... 

.. _download_Mycocosm:

Le téléchargement de la base de données Mycocosm
------------------------------------------------

La session suivante, nous montre comment télécharger la base de données Mycocosm.

Programme
~~~~~~~~~

Nom du programme::

   download_mycocosm_scaffolds.sh

Localisation
~~~~~~~~~~~~

.. code-block:: sh

   └── src
    ├── download
    │   ├── download_mycocosm_scaffolds.sh

Pour pouvoir télécharger les séquences de Mycocosm plusieurs étapes doivent être réalisées.

(1) Créer un compte sur le site du JGI *Joint Genome Institure* https://contacts.jgi.doe.gov/registration/new

(2) Confirmer votre inscription par mail.

(3) Exécuter le programme.

Exemple d'utilisation
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: sh

      bash src/download/download_mycocosm_scaffolds.sh \
                        -username mail@a.com\
                        -password azerty \
                        -path_output data/raw_sequences/mycoccosm_fungi_ncbi_scaffolds/

Dans cet exemple, nous téléchargeons les scaffolds de la base de données Mycocosm en indiquant notre adresse mail avec le mot de passe associé (l'adresse mail et le mot de passe sont donnés ici à titre d'exemple et ne sont pas utilisables). Nous indiquons ensuite le chemin de sortie avec le paramètre -path_output, ici les scaffolds irons dans le dossier de sortie data/raw_sequences/mycoccosm_fungi_ncbi_scaffolds/ .

Dépendances
~~~~~~~~~~~

Le programme dépend de deux scripts Python :

::

   src/download/download_scaffold_mycocosm_jgi.py

**download_scaffold_mycocosm_jgi.py** permet de télécharger le cookie, le fichier xml, les séquences scaffolds, de créer un fichier récapitulatif en csv des espèces avec leurs noms etc.. 

Le second script est :

::

   src/python/jgi_id_to_ncbi_id_taxonomy.py

**jgi_id_to_ncbi_id_taxonomy.py**
