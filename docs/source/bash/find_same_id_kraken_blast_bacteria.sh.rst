Comparer les identifiants taxonomiques entre Kraken et Blast
============================================================

Le programme shell qui permet de récupérer les identifiant du même genre s'appelle :

.. hint:
   find_same_id_kraken_blast_bacteria.sh

Localisation
************


.. code-block:: sh

   └── src
    ├── bash
    │   ├── find_same_id_kraken_blast_bacteria.sh

Description
***********

Pour chaque échantillon et pour chaque reads alignés le programme :
   #. compare les identifiants taxonomiques Blast et Kraken et ne conserve que ceux qui sont du même genre,
   #. compte le nombre de reads pour chaque espèce,
   #. dessine la carte de couverture des Viruses,
   #. et récupère les noms des espèces pour remplacer les ID taxonomiques.


.. warning::
   Il peut être important d'utiliser l'environnement conda "metagenomic_env" pour le bon déroulement des scripts.

.. warning::
   Le programme dépend de plusieurs sous programme qui sont :
   * sort_blasted_seq.py

.. note::
   Les programmes python se trouvent dans le dossier src/python/ .

Les paramètres d'entrés
***********************

  * :-path_taxo:

    (Input)  The path of folder with Bacteria or Viruses or (Fongi) folders          \*DIR: input_bacteria_folder

  * :-path_blast:

    (Input)  The folder of the blast results containing .blast.txt.                  \*DIR: input_results_blast

  * :-path_ncbi:

    (Input)  The folder of ncbi taxonomy containing .taxa.sqlite .                   \*DIR: input_blast_taxa_db


Exemple d'execution
*******************

.. code-block::

   ./find_same_id_kraken_blast_bacteria.sh \
   -path_taxo ../../results/test/bacteria_reads_clean_fda_refseq_human_viral_07_05_2020/ \
   -path_blast ../../results/test/bacteria_metaphlan_blast_clean_fda_refseq_human_viral_07_05_2020/ \
   -path_ncbi ../../data/databases/ete3_ncbi_taxanomy_database_05_05_2020/

.. note::

   A noter que si le paramètre -path_ncbi n'est pas précisé le programme va par défault choisir le chemin suivant: ~/.etetoolkit/ pour trouver la base de données taxa.sqlite. Si aucune base de donnée n'est retrouvée c'est peut-être parce que la base de donnée taxonomique de ncbi n'a pas été télécharger. Nous pouvons télécharger cette base de donnée grace au programme download_ete3_ncbi_taxa_db.sh (dans le dossier src/download/).


    # Get all blast files (*.blast) for bacteria.
    BLAST_FILES=$(ls $BLAST_FOLDER | grep -i blast)
    echo -e "Blast files for Bacteria are : \n$BLAST_FILES"

    # Classified sequences change blast.txt to clseqs_*.fastq .
    # clseqs1=$(echo $BLAST_FILES | sed "s/blast.txt/clseqs_1.fastq/g")
    # clseqs2=$(echo $BLAST_FILES | sed "s/blast.txt/clseqs_2.fastq/g")

    # echo "clseqs1 : $clseqs1"
    # echo "clseqs2 : $clseqs2"

    # # Conserved variable change blast.txt to conserved.txt .
    # conserved=$(echo $BLAST_FILES | sed "s/blast.txt/conserved.txt/g")

    # echo "conserved : $conserved"

    # # Counting variable change blast.txt to counting.txt .
    # counting=$(echo $BLAST_FILES | sed "s/blast.txt/countbis.txt/g")

    # echo "counting : $counting"

    # # Change variable blast.txt to temps*.txt .
    # temp1=$(echo $BLAST_FILES | sed "s/blast.txt/temp1.txt/g")
    # temp2=$(echo $BLAST_FILES | sed "s/blast.txt/temp2.txt/g")
    # temp3=$(echo $BLAST_FILES | sed "s/blast.txt/temp3.txt/g")

    # echo "temp1 : $temp1"
    # echo "temp2 : $temp2"
    # echo "temp3 : $temp3"

    # Change name variable *.blast.txt to *fasta
    NAME_BLAST_TO_FASTA=$(echo -e "\n$BLAST_FILES" | sed "s/.blast.txt/fasta/g")

    echo -e "NAME_BLAST_TO_FASTA : $NAME_BLAST_TO_FASTA"

    echo "####################Create blast folders!######################"
    # For each sample create folder with result.
    for CREATE_BLAST_FOLDERS in $NAME_BLAST_TO_FASTA
    do
        echo "Create $BLAST_FOLDER/$CREATE_BLAST_FOLDERS directory."
        mkdir -p ${BLAST_FOLDER}/$CREATE_BLAST_FOLDERS
        echo "Create $BLAST_FOLDER/$CREATE_BLAST_FOLDERS done."
    done

    echo "####################run sort_blasted_seq.py!###################"
    for EACH_BLAST_FILE in $BLAST_FILES
    do
        echo "For $EACH_BLAST_FILE in ${BLAST_FOLDER} folder."
        BASENAME_FILE=$(basename "$EACH_BLAST_FILE" .blast.txt)
        echo "Basename : $BASENAME_FILE"


        # 3 parameters :
        # -i : The blast file input e.g *.blast.txt .
        # -o : The output file for e.g *_conserved.txt 
        # -n : The localization of NCBI taxa database.
        # Output files is conserved and not_conserved ID of taxa from blast.txt .
        python ../python/sort_blasted_seq.py \
               -i ${BLAST_FOLDER}$EACH_BLAST_FILE \
               -o ${BASENAME_FILE}conserved.txt \
               -n ${PATH_NCBI_TAXA}taxa.sqlite
    done
    echo "sort_blasted_seq.py Done"

    # # Part of the code that I really don't understand.
    # cat ${FOLDER_TAXO}/${conserved} | awk -v pathF="${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}" \
    #                                       -F "[\t]" '\''$10~/^1/ {print $1" "$8 > pathF"/map1.fa" ; print $1 > pathF"/1.fa" }'\'
    # cat ${BLAST_FOLDER}/${conserved} | awk -v pathF="${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}" \
    #                                        -F"[\t]" '\''$10~/^2/ {print $1" "$8 > pathF"/map2.fa" ; print $1 > pathF"/2.fa"}'\'

    # # They is no -clseqs_2 parameter ???
    # # I don't understand again.
    # bash recover_reads.sh \
    #      -reads_list ${folderInput}/${clseqs1} empty.txt \
    #      -clseqs_1 ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/1.fa \
    #      -output ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/1.fasta

    # bash recover_reads.sh \
    #      -reads_list ${folderInput}/${clseqs2} empty.txt \
    #      -clseqs_1 ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/2.fa \
    #      -output ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/2.fasta

    # # I don't know WTF.
    # cat ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/1.fasta | paste - - | cut -c2- | sort > ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/sorted1.fasta
    # cat ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/2.fasta | paste - - | cut -c2- | sort > ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/sorted2.fasta

    # # Sort map1 and map2 and get outputs sorted1.fa and sorted2.fa
    # # before joining else join command bug.
    # sort ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/map1.fa \
    #      --output ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/sorted1.fa
    # sort ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/map2.fa \
    #      --output ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/sorted2.fa

    # # Join something.
    # join -1 1 -2 1 ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/sorted1.fasta ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/sorted1.fa > ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/1.fasta
    # join -1 1 -2 1 ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/sorted2.fasta ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/sorted2.fa > ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/2.fasta

    # #
    # cat ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/1.fasta | awk -v pathF="${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}" '\''{print ">"$1" "$2" "$3"\n"$4 > pathF"/"$5".fasta"}'\'
    # cat ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/2.fasta | awk -v pathF="${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}" '\''{print ">"$1" "$2" "$3"\n"$4 >> pathF"/"$5".fasta"}'\'

    # # Remove
    # rm ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/1.fasta \
    #    ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/2.fasta \
    #    ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/1.fa \
    #    ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/2.fa

    # rm ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/map1.fa \
    #    ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/map2.fa \
    #    ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/sorted1.fa \
    #    ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/sorted2.fa

    # rm ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/sorted1.fasta \
    #    ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/sorted2.fasta

    # # WTF men !
    # find ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA} -type f |
    #     while read f; do
    #         i=0
    #         while read line; do
    #             i=$((i+1))
    #             [ $i -eq 10 ] && continue 2
    #         done < "$f"
    #         printf %s\\n "$f"
    #     done |
    #     xargs rm -f

    # #
    # sort -n ${BLAST_FOLDER}/${conserved} -k8,8 \
    #      --output ${BLAST_FOLDER}/{}sorted.txt

    # #
    # rm ${BLAST_FOLDER}/${conserved}

    # #
    # mv ${BLAST_FOLDER}/{}sorted.txt ${BLAST_FOLDER}/${conserved}

    # #
    # cut -f8 ${BLAST_FOLDER}/${conserved} | uniq -c | sort -k2,2 -g > ${BLAST_FOLDER}/${temp1}
    # cut -f2,8 ${BLAST_FOLDER}/${conserved} | sort -k1 | uniq | cut -f2 | sort -g | uniq -c > ${BLAST_FOLDER}/${temp2}

    # #
    # join -1 2 -2 2 ${BLAST_FOLDER}/${temp1} ${BLAST_FOLDER}/${temp2} | sort -k1,1b > ${BLAST_FOLDER}/${temp3}
    # join -1 1 -2 1 ${BLAST_FOLDER}/${temp3} /data2/home/masalm/Antoine/DB/MetaPhlAn/totalCountofGenes.txt | sort -k2,2 -gr > ${BLAST_FOLDER}/${counting}

    # #
    # python ../python/get_names.py ${BLAST_FOLDER}/${counting}

    #
    # rm ${BLAST_FOLDER}/${counting}
    # rm ${BLAST_FOLDER}/${temp1} ${BLAST_FOLDER}/${temp2} ${BLAST_FOLDER}/${temp3}
else
    echo "Bacteria directory doesn't exists."
fi

# Deactivate conda environment.
conda deactivate
