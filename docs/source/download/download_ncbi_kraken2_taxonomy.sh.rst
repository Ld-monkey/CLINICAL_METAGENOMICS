Télécharger la taxonomie NCBI de Kraken 2
=========================================

Le script qui permet d'automatiser le téléchargement de la base de données taxonomique NCBI nécessaire pour Kraken 2 est :

.. hint::
   download_ncbi_kraken2_taxonomy.sh

.. warning::
   Il peut être important d'utiliser l'environnement conda "metagenomic_env" pour utiliser kraken 2 et télécharger la base de données taxonomique.

Localisation
************

.. code-block:: sh

   └── src
    ├── download
    │   ├── download_ncbi_kraken2_taxonomy.sh


Les paramètres d'entrée
***********************

   * :-output_taxonomy:

   (Output) Le chemin du dossier de sortie qui va contenir les éléments téléchargés de la base de données taxonomique de NCBI.                 \*DIR: path_taxonomy/

   * :-force_download:

   (Input) Paramètre ou flag qui est par défaut sur "no", empêche d'écraser la base de données taxonomique lorsque celle-ci existe déjà. En revanche, le paramètre est défini sur "yes" une nouvelle base de données taxonomique sera téléchargée. Si la base de données taxonomique n'existe pas elle sera créée.
     \*STR: yes||no

.. note::
   Par défaut force_downlaod est définit sur "no".


Exemples exécution
*******************

Pour créer une base de données taxonomiques NCBI lorsque que celle-ci n'existe pas à l'emplacement data/taxonomy/ncbi_taxonomy_2020/ .

.. code-block:: sh

   bash src/download/download_ncbi_kraken2_taxonomy.sh -output_taxonomy data/taxonomy/ncbi_taxonomy_2020/

Pour écraser une base de données taxonomique pré-existante et la renouveler exécuter la commande suivant :

.. code-block:: sh

   bash src/download/download_ncbi_kraken2_taxonomy.sh -output_taxonomy data/taxonomy/ncbi_taxonomy_2020/ -force_download yes


Message d'erreur
****************

Vous pouvez rencontrer le message d'erreur suivant :

.. warning::
   <folder> taxonomy already exists.
   But -force_download is set to no by default.
   To remove old taxnomy folder you should to set the marameter to -force_download yes
   Nothing is downloaded

Utiliser le paramètre -force_download en mode "yes" pour forcer le téléchargement de la base de données taxonomique de NCBI.
