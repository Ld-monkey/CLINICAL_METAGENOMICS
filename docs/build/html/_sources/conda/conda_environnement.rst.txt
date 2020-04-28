Environnement Conda
===================

.. warning::
   Si le message d'erreur apparait CommandNotFoundError: Your shell has not been properly configured to use 'conda activate'.
   To initialize your shell, run
   \$ conda init <SHELL_NAME>

.. note::
   Pour résoudre le problème sur les distributions Linux executer le code suivant dans un terminal ce qui va exporter les variables de conda dans votre shell (~/.bashrc). Ensuite ouvrir une nouvelle fenêtre shell.

.. code-block:: sh
   
   echo -e "export -f conda\nexport -f __conda_activate\nexport -f __conda_reactivate\nexport -f __conda_hashr\nexport -f __add_sys_prefix_to_path" >> ~/.bashrc

Pour créer un environnement conda a partir du fichier yaml (metagenomic_env.yml) :

.. code-block:: sh

   conda env create -f metagenomic_env.yml

Pour activer l'environnement conda :

.. code-block:: sh

   conda active metagenomic_env

Pour désactiver l'environnement conda :

.. code-block:: sh

   conda deactivate


Pour supprimer l'environnement :

.. code-block:: sh

   conda env remove -n metagenomic_env
