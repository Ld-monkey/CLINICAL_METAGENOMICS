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

Le premier script Python est :

::

   src/download/download_scaffold_mycocosm_jgi.py

**download_scaffold_mycocosm_jgi.py** va télécharger :

   * le cookie,
   * le fichier xml,
   * les séquences scaffolds,
   * et créer un fichier récapitulatif en format csv *(Comma-separated values)*. 

Le second script Python est :

::

   src/python/jgi_id_to_ncbi_id_taxonomy.py

**jgi_id_to_ncbi_id_taxonomy.py** associe les identifiants taxonomiques utilisés par JGI dans les scaffold et convertit en identifiant taxonomique du NCBI.

.. note::
   Cette conversion est nécessaire car elle permet l'indexation des bases de données avec le logiciel Kraken 2. Kraken 2 (utilisé dans la suite du tutoriel) utilise et la taxonomie de référence du NCBI et l'algorithme de k-mer pour classifier les reads rapidement (voir section ..) 


.. _indexation_kraken2:

L'indexation d'une base de données avec Kraken 2
------------------------------------------------

Le logiciel Kraken 2 propose :

1. l'indexation avec l'algorithme de k-mer d'une base de données,
2. la classification taxonomique des reads.

.. note::
   L'étape d'indexation de la base de données est la plus coûteuse en ressources et en temps. Une fois construite, la base de données de Kraken 2 est conservée, et n’a besoin d’être reconstruite que si une mise à jour est nécessaire.


La théorie
~~~~~~~~~~

.. image:: images/indexation_kraken_2.png
   :width: 400
   :alt: Indexation des librairies de séquences avec Kraken 2
   :align: right

Schéma des étapes d'indexation d'une base de données avec le logiciel Kraken 2 (image par Zygnematophyce).

1. Une base de données est une librairie de génomes (étape 1) qui recense l’ensemble des séquences génomiques.
2. Pour indexer la base de données sélectionnée, l’algorithme de Kraken 2 va ensuite hacher (étape 2) chaque génome de la base de données en fragments appelés k-mers de 31 nucléotides.
3. Chaque k-mer est ajouté à la base de données et obtient un numéro d’identification taxonomique (étape 3). Si c’est un nouveau k-mer, l’identifiant taxonomique de l’espèce d‘où il provient lui est associé.

.. note::
     Si le k-mer est déjà présent dans la base de données, l’ancêtre commun le plus proche (LCA) des deux identifiants taxonomiques est utilisé pour identifier ce fragment.

.. seealso:: Les informations sur les taxons sont obtenues à partir de la base de données taxonomique du NCBI.

La pratique
~~~~~~~~~~~

La session qui suit, nous montre comment indexer la base de données avec l'algorithme de k-mer et l'outil Kraken 2.

Programme
~~~~~~~~~

Nom du programme::

   create_kraken_database.sh

Localisation
~~~~~~~~~~~~

.. code-block:: sh

   └── src
    ├── bash
    │   ├── create_kraken_database.sh


Exemple d'utilisation
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: sh

   bash src/bash/create_kraken_database.sh \
                -path_seq data/raw_sequences/fda_argos_raw_genomes_assembly_06_06_2020/ \
                -path_db data/databases/kraken_2/fda_argos_with_none_library_kraken_database_07_06_2020/ \
                -type_db none \
                -threads 30

Dans cet exemple, nous créons une base de données indexée à partir d'une librairie de séquence. Ici, les séquences assemblées de la base de données FDA-ARGOS qui se trouvent dans data/raw_sequences/fda_argos_raw_genomes_assembly_06_06_2020/ est la librairie choisie (voir :ref:`Le téléchargement de la base de données FDA-ARGOS <download_FDA_ARGOS>`). Ensuite, avec le paramètre -path_db nous précisons le chemin de sortie pour notre base de données indexée ici le chemin sera data/databases/kraken_2/fda_argos_with_none_library_kraken_database_07_06_2020/.

Le paramètres -type_db est le paramètre qui détermine le type de la base de données. Nous avons choisi de ne pas rajouter d'autre libraire à notre base de données notre type est donc "none". 

.. note::
   Kraken 2 propose une multitude de librairies qui peuvent être rajoutées à notre base de données. La liste non exhaustive des possibilités :

   * none : Paramètre qui empêche le téléchargement et l'installation d'une ou plusieurs bibliothèques de référence
   * bacteria : RefSeq génomes / protéines bactériens complets
   * viral : RefSeq génome / protéines virales complètes
   * human : génome / protéines humains GRCh38
   * fungi : RefSeq génomes / protéines fongiques complets
   * ...

.. seealso::
   Pour voir l'ensemble de la liste : https://github.com/DerrickWood/kraken2/wiki/Manual#custom-databases

Et enfin le nombre de threads pour accélérer le processus, ici le nombre de threads est à 30.


Les paramètres
~~~~~~~~~~~~~~

:-path_seq: (Input) Chemin du dossier de la librairie de séquences sous format fna ou fasta.
:-path_db: (Output) Chemin du dossier de sortie pour créer et indexer notre base de données.
:-type_db: (Input) Quel type de librairie ajouter à notre base de données (choix : none, viral, fungi ...).
:-threads: (Input) Le nombre de threads pour indexer la base de données plus rapidement.
:-taxonomy: (Optional) Dossier contenant la taxonomie du NCBI téléchargée par Kraken 2.

.. note::
   Dans le cas où l’on a téléchargé la taxonomie du NCBI en dehors de Kraken 2, on peut préciser le paramètre -taxonomy. Par défaut, le script va télécharger la taxonomie du NCBI automatiquement si le paramètre n’est pas précisé.

Les fichiers de sorties
~~~~~~~~~~~~~~~~~~~~~~~

Les fichiers de sorties sont les suivants :

   * **hash.k2d** : Les mappages de taxons.
   * **opts.k2d** : Les options utilisées pour créer la base de données.
   * **taxo.k2d** : Les informations taxonomique utilisées pour créer la base de données.

.. note::
   Par défaut, le script supprime les fichiers intermédaires.
