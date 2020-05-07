Comparer les identifiants taxonomiques entre Kraken et Blast
============================================================

Le programme shell qui permet de récupérer les identifiant du même genre s'appelle :

.. hint::
   find_same_id_kraken_blast_bacteria.sh

Localisation
************

.. code-block:: sh

   └── src
    ├── bash
    │   ├── find_same_id_kraken_blast_bacteria.sh

Description
***********

Pour chaque échantillons et pour chaque reads alignés le programme :

   #. compare les identifiants taxonomiques Blast et Kraken et ne conserve que ceux qui sont du même genre,
   #. compte le nombre de reads pour chaque espèce,
   #. dessine la carte de couverture des viruses,
   #. et récupère les noms des espèces pour remplacer les ID taxonomiques.


.. warning::
   Il peut être important d'utiliser l'environnement conda "metagenomic_env" pour le bon déroulement des scripts.

.. warning::
   Le programme dépend de plusieurs sous programme qui sont :
   sort_blasted_seq.py

.. note::
   Les programmes python se trouvent dans le dossier src/python/ .

Les paramètres d'entrés
***********************

  * :-path_taxo:

    (Input)  The path of folder with Bacteria or Viruses or (Fongi) folders          \*DIR: input_bacteria_folder

  * :-path_blast:

    (Input)  The folder of the blast results containing .blast.txt.                  \*DIR: input_results_blast

  * :-path_ncbi:

    (Input)  The folder of ncbi taxonomy containing .taxa.sqlite .                   \*DIR: input_blast_taxa_db

.. note::

   A noter que si le paramètre -path_ncbi n'est pas précisé le programme va par défault choisir le chemin suivant: ~/.etetoolkit/ pour trouver la base de données taxa.sqlite. Si aucune base de donnée n'est retrouvée c'est peut-être parce que la base de donnée taxonomique de ncbi n'a pas été télécharger. Nous pouvons télécharger cette base de donnée grace au programme download_ete3_ncbi_taxa_db.sh (dans le dossier src/download/).

Exemple d'execution
*******************

.. code-block:: sh

   ./find_same_id_kraken_blast_bacteria.sh \
   -path_taxo ../../results/test/bacteria_reads_clean_fda_refseq_human_viral_07_05_2020/ \
   -path_blast ../../results/test/bacteria_metaphlan_blast_clean_fda_refseq_human_viral_07_05_2020/ \
   -path_ncbi ../../data/databases/ete3_ncbi_taxanomy_database_05_05_2020/

Les fichiers de sorties pour la comparaison d'identifiants taxonomiques
***********************************************************************

.. note::
   Dans le dossier ou se trouve les résultats des blasts, un dossier pour chaque fichier blast sera créés. Ce dossier comprend les identifiants taxonomiques qui sont conservés. Les identifiants taxonomiques qui sont conservées entre Blast et Kraken sont les identifiants du même genre.

Les fichiers de sortie sont :

   * \*_conserved.txt : Les identifiants taxonomiques conservés.
   * \*_notconserved.txt : Les identifiants taxonomiques qui ne sont pas conservés.

Exemple d'un fichier avec des identifiants conversés :
------------------------------------------------------

.. code-block:: sh

   NB552188:4:H353CBGXC:4:22605:9229:16747 gi|422547321|ref|NZ_GL383459.1|:130129-130737   356     446     5e-41   169     609     765102  1747    1
   NB552188:4:H353CBGXC:2:22205:2911:15651 gi|490241673|ref|NZ_CALM01000137.1|:c5103-4639  1       85      1e-30   135     465     1118157 40324   1
 
A suivre ...
************
