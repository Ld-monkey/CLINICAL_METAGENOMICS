Télécharger la taxonomie de ncbi avec ete3toolkit
=================================================

Le script Shell suivant permet d'automatiser le téléchargement de la taxonomie nécessaire pour la librairie python ete3.

.. hint::
   download_ete3_ncbi_taxa_db.sh

Cette base de données taxonomique peut-être importante dans certain programme. En autre le chemin de cette base de données est un paramètre (-path_ncbi) du programme Shell find_same_id_kraken_blast.sh .

.. warning::
   Il peut être important d'utiliser l'environnement conda "metagenomic_env" pour le bon déroulement des scripts.

.. warning::
   Ce programme ci-dessus dépend du programme python appelé get_ete3_ncbi_taxa_db.py. Le programme python se trouve dans le dossier src/python/ .

Les bases de données
********************
Les bases de données générées sont :

   * taxa.sqlite
   * taxa.sqlite.traverse.pkl

Localisation
************

.. code-block:: sh

   └── src
    ├── download
    │   ├── download_ete3_ncbi_taxa_db.sh


.. note::
   Le programme va stocker la base de données dans le répertoire suivant :

.. code-block:: sh

   └── data
    ├── databases


.. note::
   A noter que les scripts génèrent automatiquement un dossier avec la date.


Exemple d'execution
*******************

.. code-block:: sh

   ./download_ete3_ncbi_taxa_db.sh
