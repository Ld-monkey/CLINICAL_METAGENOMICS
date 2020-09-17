Quick Start
###########


L'architecture d'un projet
--------------------------

Commençons par définir l'architecture que prendra une analyse de métagénomique avec le pipeline. Pour cela, nous voulons qu’à chaque étape importante du pipeline comprendre instinctivement l'analyse et les résultats qui se trouvent dans chaque dossier.

.. note::
   Les noms associés aux dossiers seront subjectifs et pourront toujours être changés par la suite. 


L'architecture choisie est la suivante :

.. code-block:: sh

   results/
   ├── {DATE}/
       ├── all_plots
       ├── all_reports
       ├── post_blast_classification
       ├── convert_fastq_to_fasta
       ├── filtered_sequences
       ├── kraken2_classification
       ├── same_taxonomics_id_kraken_blast
       └── trimmed_reads
