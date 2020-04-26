Environnement Conda
===================

Pour créer un environnement conda a partir du fichier yaml (conda_threader.yml) :


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
