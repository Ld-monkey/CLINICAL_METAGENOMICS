Récupérer les identifiants taxonomiques du même genre taxonomique entre Kraken et Blast
========================================================================================


Recover sequence with conserved classification between Kraken2 and BLAST. This program allow to separate the sequences : those which have a similar taxonomy at the genus level are gathered in the file "conserved.txt" (output).

Les paramètres d'entrés
***********************

Les 3 paramètres sont :

   * -i : The blast file input e.g \*.blast.txt .
   * -o : The output file for e.g \*_conserved.txt 
   * -n : The localization of NCBI taxa database.

Exemple d'exécution
*******************

.. code-block:: sh

   python ../python/sort_blasted_seq.py \
   -i ${BLAST_FOLDER}$EACH_BLAST_FILE \
   -o ${BASENAME_FILE}conserved.txt \
   -n ${PATH_NCBI_TAXA}taxa.sqlite
