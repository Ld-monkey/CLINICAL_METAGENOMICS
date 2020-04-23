# CLINICAL METAGENOMICS
[![Documentation Status](https://readthedocs.org/projects/clinical-metagenomics/badge/?version=latest)](https://clinical-metagenomics.readthedocs.io/fr/latest/?badge=latest)

## Introduction

## Configuration 

### Environnement conda :
Pour créer un environnement conda a partir du fichier yaml (conda_threader.yml) :

```bash
conda env create -f metagenomic_env.yml
```

Pour activer l'environnement conda :

```bash
conda active metagenomic_env
```

Pour désactiver l'environnement conda :

```bash
conda deactivate
```

Pour supprimer l'environnement :

```
conda env remove -n metagenomic_env
```

### Automatisation avec snake

### Configuration de la documentation
La documentation utilise [sphinx](https://www.sphinx-doc.org/en/master/) et le thème "sphinx-rtd-theme" que l'on peut retrouver sur https://github.com/readthedocs/sphinx_rtd_theme.

Le thème peut etre facilement installé avec pip3 :

```bash
pip3 install sphinx-rtd-theme
```

## Documentation

La documentation se trouve dans le lien suivant :

* https://clinical-metagenomics.readthedocs.io/fr/latest/

## Objectifs

Inspiré de l'article :
* Lee BD (2018) Ten simple rules for documenting scientific software. PLoS Comput Biol 14(12): e1006561. https://doi.org/10.1371/journal.pcbi.1006561

- [x] Inclure un fichier README.md
- [x] Documenter mon code (avec Sphinx) (en cours).
- [ ] Inclure un quickstart guide.
- [ ] Inclure des exemples.
- [ ] Ajouter l'option -h ou help commande pour chaque fichier bash.
- [ ] Intégrer des messages d'erreurs et fournir une solution dans la documentation.

