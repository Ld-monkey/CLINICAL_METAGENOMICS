# KRAKEN2 CLUSTER
Configuration des fichiers bash pour automatiser la création des bases de données personnalisées sur le cluster. La création des bases de données nous permettent de réaliser des analyses de méta-génomique.

## Lancer la création d'une base de données sur le cluster
```bash
qsub build_database_cluster.sh
```

## Les paramètres de FDA_database_kraken2.sh
```bash
  -ref      (Input) folder path of other sequences file fna                                               *FILE: sequences.fna
  -database (Input) folder path to create or view the database                                            *DIR: database
  -threads  (Input) the number of threads to build the database faster                                   *INT: 6
```

## Exemple d'utilisation de FDA_database_kraken2.sh
```bash
./FDA_database_kraken2.sh -ref test -database database -threads 1
```