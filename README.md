# CLINICAL METAGENOMICS

## Introduction

## Configuration 
### Environnement conda

### Automatisation avec snake

### Configuraiton de la documentation
La documentation utilise [sphinx](https://www.sphinx-doc.org/en/master/) et le thème "sphinx-rtd-theme" que l'on peut retrouver sur https://github.com/readthedocs/sphinx_rtd_theme.

Le thème peut etre facilement installé avec pip3 :

```bash
pip3 install sphinx-rtd-theme
```

Pour etre intégrer au projet sphinx, vous devez ajouter les lignes suivantes dans le fichier conf.py :

```python
import sphinx_rtd_theme

extensions = [
    ...
    "sphinx_rtd_theme",
]

html_theme = "sphinx_rtd_theme"
```

## Objectifs

Inspiré de l'article :
* Lee BD (2018) Ten simple rules for documenting scientific software. PLoS Comput Biol 14(12): e1006561. https://doi.org/10.1371/journal.pcbi.1006561

- [x] Inclure un fichier README.md
- [x] Documenter mon code (avec Sphinx) (en cours).
- [ ] Inclure un quickstart guide.
- [ ] Inclure des exemples.
- [ ] Ajouter l'option -h ou help commande pour chaque fichier bash.
- [ ] Intégrer des messages d'erreurs et fournir une solution dans la documentation.

