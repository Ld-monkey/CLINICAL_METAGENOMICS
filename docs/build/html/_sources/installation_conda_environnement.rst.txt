Installation
############

L'installation du projet est facilité par l'utilisation de Conda.

Conda est un gestionnaire de paquets, il permet de créer son propre environnement virtuel contenant les logiciels informatiques nécessaires au fonctionnement du pipeline de métagénomique (exemple Kraken 2, la suite blast-plus etc...). Pour créer un environnement conda à partir du fichier yaml (metagenomic_env.yml) :

Télécharger le projet sur github
--------------------------------

Télécharger le projet

.. code-block:: sh

   git clone https://github.com/Zygnematophyce/CLINICAL_METAGENOMICS.git

Création de l'environnement conda
---------------------------------

Pour créer un environnement conda à partir du fichier yaml (metagenomic_env.yml) :

.. code-block:: sh

   conda env create -f metagenomic_env.yml

Pour supprimer définitivement l'environnement :

.. code-block:: sh

   conda env remove -n metagenomic_env

.. note::
   De manière générale, une fois l'environnement conda installé on ne le supprime pas à chaque fois. La dernière ligne de commande est à titre d'information dans le cas ou vous voulez supprimer définitivement l'environnement conda.


Activation de l'environnement conda
-----------------------------------

Pour activer l'environnement conda :

.. code-block:: sh

   conda active metagenomic_env

Pour désactiver l'environnement conda :

.. code-block:: sh

   conda deactivate

Les messages d'erreurs
----------------------

Dans certains cas, des messages d'erreurs peuvent survenir.

.. warning::
   CommandNotFoundError: Your shell has not been properly configured to use 'conda activate'.
   To initialize your shell, run
   \$ conda init <SHELL_NAME>

Dans ce cas et pour les distributions Linux, exécuter la commande suivante dans un terminal. 

.. code-block:: sh

   echo -e "export -f conda\nexport -f __conda_activate\nexport -f __conda_reactivate\nexport -f __conda_hashr\nexport -f __add_sys_prefix_to_path" >> ~/.bashrc

Ensuite ouvrir un nouveau terminal.
