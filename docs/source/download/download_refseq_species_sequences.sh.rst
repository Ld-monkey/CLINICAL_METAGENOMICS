Télécharger les séquences des espèces virales et bactériennes
=============================================================

Dans ce projet nous avons créé des scripts en Bash qui automatise le téléchargement des bases de données. Ces bases de données sont spécifiques à notre étude.


Les scripts qui permettent d'automatiser le téléchargement et le traitement des données sont :

.. hint::
   download_refseq_viral_sequences.sh

   download_refseq_bacterial_sequences.sh

.. warning::
   Il peut être important d'utiliser l'environnement conda "metagenomic_env" pour le bon déroulement des scripts.

Les bases de données
********************
Les bases de données sont :

   * Les séquences nucléotidiques de toutes les espèces virales de refseq.
   * Les séquences nucléotidiques de tous les espèces bactériennes de refseq.

Localisation
************

.. code-block:: sh

   └── src
    ├── download
    │   ├── download_refseq_viral_sequences.sh
        ├── download_refseq_bacterial_sequences.sh

.. warning::
   Les programmes ci-dessus ont besoin du script en perl "makemap.pl" pour fonctionner. Le programme "makemap.pl" permet d'extraire les séquences fasta et leurs références taxonomiques.

.. note::
   Le programme va stocker le téléchargement dans le répertoire suivant :

.. code-block:: sh

   └── data
    ├── raw_sequences
    │   ├── bacteria_sequences_from_refseq_01_05_2020

.. note::
   A noter que les scripts génèrent automatiquement un dossier avec la date.


Exemple d'exécution
*******************

.. code-block:: sh

   ./download_refseq_viral_sequences.sh


.. code-block:: sh

   ./download_refseq_bacterial_sequences.sh

Les fichiers d'entrées
**********************

Les fichiers d'entrées sont les suivants :

   * \*.gbff.gz : Le format génomiques de genbank dans ncbi.

Les fichiers de sorties
***********************

Les fichiers de sorties sont les suivants :


   * \*.fasta : L'extraction des séquences fasta.
   * all_genomic_$specie_sequences.fasta : Le regroupement dans un seul fichier de toutes les séquences fasta.
   * \*.map : L'extraction des références taxonomiques.
   * \$specie_map.complete : Le regroupement dans un seul fichier de toutes les références taxonomiques. 
