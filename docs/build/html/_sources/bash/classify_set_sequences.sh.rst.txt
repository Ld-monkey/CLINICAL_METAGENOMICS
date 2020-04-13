Classifier les séquences
========================

Le programme shell qui permet d'executer la classification d'organismes s'appelle :

.. hint::
   classify_set_sequences.sh

Localisation
************

.. code-block:: sh

   └── src
    ├── bash
    │   ├── classify_set_sequences.sh

Description
***********

Détermine les organismes présent dans un échantillon ou reads. L'échantillon possède la totalité des séquences nucléotidique avec un format fastq.

.. warning::
   Les séquences par paires doivent s'appeler \*R1\*.fastq

.. note::
   \* L'étoile indique que n'importe quelle chaine de caractère peut se positionner avant ou après.

Les paramètres d'entrés
***********************

Exemple d'execution
*******************

.. code-block:: sh

   classify_set_sequences.sh all_reads_from_sample output_database_FDA_ARGOS 1 output_result

Les fichiers de sorties
***********************

Les fichiers de sorties sont les suivants : \*.clseqs\_\*.fastq, \*.unclseq_*.fq, \*.output.txt, \*.report.txt .

   * \*.clseqs.fastq : Tous les reads classés.
   * \*.unclseqs.fastq : Tous les reads non-classés.
   * \*.output.txt : ?.
   * \*.report.txt : La phylogénie des organismes qui sont classés avec succès.

Le code complet
***************

.. code-block:: sh

   # First argument take the path of metagenomic read.
   PATH_ALL_READS=$1

   # Seconde argument take the path of database containt hash.k2d + opts.k2d + taxo.k2d .
   DBNAME=$2

   # Thirds argument is the number of cpu.
   THREAD=$3

   # 4th argument the folder of output kraken 2 taxonomy.
   FOLDER_OUTPUT=$4

   # Check if all sequences are unziped.
   sequences_unzip=$(ls $PATH_ALL_READS/*.gz 2> /dev/null | wc -l)
   if [ "$sequences_unzip" != 0 ]
   then
       echo "Unzip all sequences files"
       gunzip $PATH_ALL_READS/*.gz
       echo "$PATH_ALL_READS Unzip done !"
   else
       echo "$PATH_ALL_READS files are already decompressed"
   fi

   # Check if the folder for output kraken 2 results exists.
   if [ -d $FOLDER_OUTPUT ]
   then
       echo "$FOLDER_OUTPUT folder already exits."
   else
       mkdir $FOLDER_OUTPUT
       echo "Create folder $FOLDER_OUTPUT "
   fi

   # After created database we can classify a set of sequences with kraken2.
   # change with --paired + --output parameters
   echo "Run classify a set of sequences with kraken 2"
   for all_sequences in $PATH_ALL_READS/*R1*.fastq
   do
       prefix=$(basename "$all_sequences" | awk -F "R1" '{print $1}')
       suffix=$(basename "$all_sequences" | awk -F "R1" '{print $2}')
       paired_file="$prefix""R2""$suffix"
       echo "In the sequence : $all_sequences"
       echo "The prefix name file is : $prefix"
       echo "The suffix name file is : $suffix"
       echo "So the name of his paired file is : $paired_file"
       kraken2 --db $DBNAME --threads $THREAD --paired --report $FOLDER_OUTPUT/$prefix.report.txt --classified-out $FOLDER_OUTPUT/$prefix.clseqs#.fastq --unclassified-out $FOLDER_OUTPUT/$prefix.unclseq#.fq --output $FOLDER_OUTPUT/$prefix.output.txt $all_sequences $PATH_ALL_READS/$paired_file
   done
