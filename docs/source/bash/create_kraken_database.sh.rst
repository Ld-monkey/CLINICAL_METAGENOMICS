Créer les bases de données personnalisées avec Kraken 2
=======================================================

Le programme shell qui permet de créer une base de données kraken 2 personnalisées est :

.. hint::
   create_kraken_database.sh


Localisation
************

.. code-block:: sh

   └── src
    ├── bash
    │   ├── create_kraken_database.sh

Description
***********

Créer une base de donnée personnalisée avec l'outil Kraken 2. Nous pouvons ajouter des séquences spécifiques ou encore ajouter ultérieurement des séquences dans la base de donnée.

Les paramètres d'entrés
***********************

   * :-ref:

   (Input) Le chemin du fichier contenant les séquences au format .fna
   
   * :-database:

   (Input) Le chemin de la base de donnée pour la créer ou l'actualiser.
   
   * :-threads:

   (Input) Le nombre de puissance (threads) pour créer la base de donnée plus rapidement.

Exemple d'execution
*******************

.. code-block:: sh

   create_kraken_database.sh -ref /path/FDA_ARGOS -database /output_FDA_ARGOS -thread 1

Les fichiers de sorties
***********************

Les fichiers de sorties sont les suivants : hash.k2d, opts.k2d, taxo.k2d.

   * hash.k2d: contient le minimiseur pour les mappages de taxons.
   * opts.k2d: contient des informations sur les options utilisées pour créer la base de données.
   * taxo.k2d: contient les informations de taxonomie utilisées pour créer la base de données.
