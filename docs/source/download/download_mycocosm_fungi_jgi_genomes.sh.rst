La banque de séquences Mycocosm de JGI
======================================

La base de données Mycocosm est un projet de génomique fongique du Joint Genome
Institute (JGI) qui s'est associé à la communauté scientifique internationale pour soutenir l'exploration génomique des champignons. Aujourd’hui, le portail propose plus de 1000 espèces fongiques et plus de 500 familles fongiques.

Téléchargement de la librairie
******************************
Pour pouvoir télécharger les séquences de Mycocosm plusieurs étapes doivent être réalisées.

(1) Créer un compte sur le site du JGI *Joint Genome Institure* https://contacts.jgi.doe.gov/registration/new

(2) Confirmer votre inscription.

(3) Mettre dans 2 fichiers distincts :

   - Dans un fichier username (sans extension) mettre le mail utilisé lors de la création de son compte au site JGI.
   - Dans un fichier password (sans extension) mettre le mot de passe utilisé lors de la création de son compte.

.. warning::
   Les fichiers username et password sont automatiquement ignorés dans le .gitignore du projet. Ceci permet d'éviter de partager sur un projet github de l'identifiant et du mot de passe. Cependant, si vous utilisez d'autre nom de fichier pour stocker fait attention à ne pas partager ces fichiers avec des informations confidentiels sur internet.

Les 2 fichiers peuvent se retrouver dans le dossier src/download :
.. code-block:: sh

   └── src
    ├── download
    │   ├── username
    │   ├── password


(4) Exécuter les programmes pour télécharger les séquences

Au total, 1694 génomes fongiques ainsi que leurs séquences codantes ont été téléchargées.

Pour construire la base de données de métagénomique avec le logiciel Kraken 2 les séquences sont indexées avec leur référence taxonomique de NCBI. En effet, les références taxonomiques de Mycocosm ne sont pas reconnues par le logiciel Kraken 2.
