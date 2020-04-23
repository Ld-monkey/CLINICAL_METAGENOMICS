#!/bin/bash
#$ -S /bin/bash
#$ -N MetaStudStep1
#$ -cwd
#$ -o outMetaTest.out
#$ -e errMetaTest.err
#$ -q short.q
#$ -l h_rt=47:20:00
#$ -pe thread 10
#$ -l h_vmem=5G
#$ -M your@email.com

echo "JOB NAME: $JOB_NAME"
echo "JOB ID: $JOB_ID"
echo "QUEUE: $QUEUE"
echo "HOSTNAME: $HOSTNAME"
echo "SGE O WORKDIR: $SGE_O_WORKDIR"
echo "SGE TASK ID: $SGE_TASK_ID"
echo "NSLOTS: $NSLOTS"

# Pour chaque échantillon et pour chaque reads alignés, compare les identifiants
# taxonomiques Blast et Kraken et ne conserve que ceux qui sont du même genre.
# Compte le nombre de reads pour chaque espèce. Dessine la carte de couverture
# des Viruses, récupère les noms des espèces pour remplacer les ID taxonomiques.

# qsub launch_analysis.sh {folder_input_sample} {basename_result_of_blast}
# e.g $launch_analysis.sh output_preprocess_reads_clean_FDA_refseq_human_viral/ METAPHLAN_BLAST_TEST

# Activate conda environment.
source activate EnvAntL

# The path of folder with Bacteria or Viruses or (Fongi) folders.
FOLDER_INPUT_SAMPLE=$1

# Export the variable of path folder in current terminal.
export FOLDER_INPUT_SAMPLE

# Into FOLDER_INPUT_SAMPLE there must be a Viruses folder.
FOLDER_VIRUSES=$1Viruses

# Export the variable path folder of Viruse in current terminal.
#export FOLDER_VIRUSES

# Into FOLDER_INPUT_SAMPLE there must be a Bacteria folder.
FOLDER_BACTERIA=$1Bacteria

# Export the variable path folder of Bacteria in current terminal.
export FOLDER_BACTERIA

# Name of the results blast folder containing .blast.txt .
NAME_BLAST_FOLDER=$2

# begin a parallel task for virus
if [ -d $FOLDER_VIRUSES ]
then
    # Get all interresting blast file *.blast for viruses.
    blast=$(ls $FOLDER_VIRUSES | grep -i blast)
    echo "Blast files for Viruses are : $blast"

    # classified sequences change blast.txt to clseq_1.fastq .
    clseqs1=$(echo {} | sed "s/blast.txt/clseqs_1.fastq/")
    clseqs2=$(echo {} | sed "s/blast.txt/clseqs_2.fastq/")

    echo "clseqs1 : $clseqs1"
    echo "clseqs2 : $clseqs2"

    # same operation conseved variable change blast.txt to conserved.txt .
    conserved=$(echo {} | sed "s/blast.txt/conserved.txt/")

    echo "conserved : $conserved"
    
    # same operation counting variable change blast.txt to countbis.txt .
    counting=$(echo {} | sed "s/blast.txt/countbis.txt/")

    echo "counting : $counting"

    # same operation basename of fasta variable change blast.txt to fasta/ .
    basename_fasta=$(echo {} | sed "s/.blast.txt/fasta/")

    echo "basename_fasta : $basename_fasta"

    # same operation change variable blast.txt to temps* .
    temp1=$(echo {} | sed "s/blast.txt/temp1.txt/")
    temp2=$(echo {} | sed "s/blast.txt/temp2.txt/")
    temp3=$(echo {} | sed "s/blast.txt/temp3.txt/")

    echo "temp1 : $temps1"
    echo "temp2 : $temps2"
    echo "temp3 : $temps3"

    # Create basename_fasta directory in viruses folder. 
    echo "Create $basename_fasta directory"
    mkdir -p ${folderinputv}/${basename_fasta}

    # (maybe for test) remove container of viruses directory.
    echo "Remove the container of $basename_fasta folder (test)"
    rm ${folderinputv}/${basename_fasta}/*

    # Run sortblastedseq.py for ??? with {} ?? .
    # Separate the sequences : those which have a similar
    # taxonomy at the genus level are gathered in the file
    # "conserved.txt" (output).
    ./sort_blasted_seq.py ${FOLDER_VIRUSES} {}

    # Evil code begin.
    #cat ${FOLDER_VIRUSES}/${conserved} |awk -v pathF="${FOLDER_VIRUSES}/${basename_fasta}" -F"[\t]" '\''$10~/^1/ {print $1" "$8 > pathF"/map1.fa" ; print $1 > pathF"/1.fa" }'\'
    #cat ${FOLDER_VIRUSES}/${conserved} |awk -v pathF="${FOLDER_VIRUSES}/${basename_fasta}" -F"[\t]" '\''$10~/^2/ {print $1" "$8 > pathF"/map2.fa" ; print $1 > pathF"/2.fa"}'\'

    # Run RecoverReads.sh for ???
    #./RecoverReads.sh ${FOLDER_VIRUSES}/${basename_fasta}/1.fa ${folderInput}/${clseqs1} empty.txt ${FOLDER_VIRUSES}/${basename_fasta}/1.fasta
    #./RecoverReads.sh ${FOLDER_VIRUSES}/${basename_fasta}/2.fa ${folderInput}/${clseqs2} empty.txt ${FOLDER_VIRUSES}/${basename_fasta}/2.fasta

    #
    #cat ${FOLDER_VIRUSES}/${basename_fasta}/1.fasta | paste - - | cut -c2- |sort > ${FOLDER_VIRUSES}/${basename_fasta}/sorted1.fasta
    #cat ${FOLDER_VIRUSES}/${basename_fasta}/2.fasta | paste - - | cut -c2- |sort > ${FOLDER_VIRUSES}/${basename_fasta}/sorted2.fasta

    #
    #sort ${FOLDER_VIRUSES}/${basename_fasta}/map1.fa > ${FOLDER_VIRUSES}/${basename_fasta}/sorted1.fa
    #sort ${FOLDER_VIRUSES}/${basename_fasta}/map2.fa > ${FOLDER_VIRUSES}/${basename_fasta}/sorted2.fa

    #
    #join -11 -21 ${FOLDER_VIRUSES}/${basename_fasta}/sorted1.fasta ${FOLDER_VIRUSES}/${basename_fasta}/sorted1.fa > ${FOLDER_VIRUSES}/${basename_fasta}/1.fasta
    #join -11 -21 ${FOLDER_VIRUSES}/${basename_fasta}/sorted2.fasta ${FOLDER_VIRUSES}/${basename_fasta}/sorted2.fa > ${FOLDER_VIRUSES}/${basename_fasta}/2.fasta

    #
    #cat ${FOLDER_VIRUSES}/${basename_fasta}/1.fasta |awk -v pathF="${FOLDER_VIRUSES}/${basename_fasta}" '\''{print ">"$1" "$2" "$3"\n"$4 > pathF"/"$5".fasta"}'\'
    #cat ${FOLDER_VIRUSES}/${basename_fasta}/2.fasta |awk -v pathF="${FOLDER_VIRUSES}/${basename_fasta}" '\''{print ">"$1" "$2" "$3"\n"$4 >> pathF"/"$5".fasta"}'\'

    #
    #rm ${FOLDER_VIRUSES}/${basename_fasta}/1.fasta ${FOLDER_VIRUSES}/${basename_fasta}/2.fasta ${FOLDER_VIRUSES}/${basename_fasta}/1.fa ${FOLDER_VIRUSES}/${basename_fasta}/2.fa
    #rm ${FOLDER_VIRUSES}/${basename_fasta}/map1.fa ${FOLDER_VIRUSES}/${basename_fasta}/map2.fa ${FOLDER_VIRUSES}/${basename_fasta}/sorted1.fa ${FOLDER_VIRUSES}/${basename_fasta}/sorted2.fa
    #rm ${FOLDER_VIRUSES}/${basename_fasta}/sorted1.fasta ${FOLDER_VIRUSES}/${basename_fasta}/sorted2.fasta

    #
    #find ${FOLDER_VIRUSES}/${basename_fasta} -type f |

    #
    #while read f; do
    #    i=0
    #    while read line; do
    #        i=$((i+1))
    #        [ $i -eq 10 ] && continue 2
    #    done < "$f"
    #    printf %s\\n "$f"
    #done |
        
    #
    #xargs rm -f
    
    #
    #sort -n ${FOLDER_VIRUSES}/${conserved} -k8,8 > ${FOLDER_VIRUSES}/{}sorted.txt

    #
    #rm ${FOLDER_VIRUSES}/${conserved}

    #
    #mv ${FOLDER_VIRUSES}/{}sorted.txt ${FOLDER_VIRUSES}/${conserved}

    #
    #cut -f8 ${FOLDER_VIRUSES}/${conserved} | uniq -c > ${FOLDER_VIRUSES}/${temp1}
    #cut -f8 ${FOLDER_VIRUSES}/${conserved} | uniq > ${FOLDER_VIRUSES}/${temp2}

    #
    #while read p;
    #do
    #    echo -n $p" " >> ${FOLDER_VIRUSES}/${temp3}
    #    grep "kraken:taxid|"$p ${FOLDER_VIRUSES}/{} | wc -l >> ${FOLDER_VIRUSES}/${temp3}
    #done<${FOLDER_VIRUSES}/${temp2}
    
    #
    #join -1 2 -2 1 ${FOLDER_VIRUSES}/${temp1} ${FOLDER_VIRUSES}/${temp3} |sort -k2,2 -gr > ${FOLDER_VIRUSES}/${counting}

    #
    #./CreateDepthPlot.py ${FOLDER_VIRUSES} ${conserved} ${counting}

    #
    #rm ${FOLDER_VIRUSES}/${counting}
    #rm ${FOLDER_VIRUSES}/${temp1} ${FOLDER_VIRUSES}/${temp2} ${FOLDER_VIRUSES}/${temp3}
else
    echo "Viruses directory doesn't exists."
fi

# Begin a parallel task for Bacteria.
if [ -d $FOLDER_BACTERIA ]
then
    if [ -d ${FOLDER_BACTERIA}/$NAME_BLAST_FOLDER ]
    then
        echo "${FOLDER_BACTERIA}$NAME_BLAST_FOLDER exists."
    else
        echo "Error : ${FOLDER_BACTERIA}$NAME_BLAST_FOLDER doesn't exists."
        exit
    fi

    # The complete path of blast folder.
    COMPLETE_BLAST_PATH=${FOLDER_BACTERIA}/$NAME_BLAST_FOLDER
    echo "Path : $COMPLETE_BLAST_PATH"

    # Get all interresting blast file *. blast for bacteria.
    blast=$(ls $COMPLETE_BLAST_PATH | grep -i blast)
    echo "blast files for Bacteria are : $blast"

    # Classified sequences change blast.txt to clseqs_*.fastq .
    clseqs1=$(echo $blast | sed "s/blast.txt/clseqs_1.fastq/g")
    clseqs2=$(echo $blast | sed "s/blast.txt/clseqs_2.fastq/g")

    echo "clseqs1 : $clseqs1"
    echo "clseqs2 : $clseqs2"

    # Conserved variable change blast.txt to conserved.txt .
    conserved=$(echo $blast | sed "s/blast.txt/conserved.txt/g")

    echo "conserved : $conserved"

    # Counting variable change blast.txt to counting.txt .
    counting=$(echo $blast | sed "s/blast.txt/countbis.txt/g")

    echo "counting : $counting"

    # Change variable blast.txt to temps*.txt .
    temp1=$(echo $blast | sed "s/blast.txt/temp1.txt/g")
    temp2=$(echo $blast | sed "s/blast.txt/temp2.txt/g")
    temp3=$(echo $blast | sed "s/blast.txt/temp3.txt/g")

    echo "temp1 : $temp1"
    echo "temp2 : $temp2"
    echo "temp3 : $temp3"

    # Create basename_fasta variable.
    basename_fasta=$(echo $blast | sed "s/.blast.txt/fasta/g")

    # Create folder all basename_fast in blast directory.
    for folder_to_create in $basename_fasta
    do
        echo "Create $COMPLETE_BLAST_PATH/$folder_to_create directory."
        mkdir -p ${COMPLETE_BLAST_PATH}/$folder_to_create
        echo "Create $COMPLETE_BLAST_PATH/$folder_to_create done."
    done

    # 3 parameters :
    # -i : The blast file input e.g *.blast.txt .
    # -o : The output file for e.g *_conserved.txt .
    # -n : The localization of NCBI taxa database.
    echo "run sort_blasted_seq.py"
    echo "COMPLETE_BLAST_PATH : $COMPLETE_BLAST_PATH"
    for interest_blast in $blast
    do
        echo "File used in sort_blasted_seq.py is : ${COMPLETE_BLAST_PATH}/$interest_blast "
        echo "$interest_blast"
        basename_=$(basename "$interest_blast" .blast.txt)
        echo "Basename : $basename_"

        # Output files is conserved and not_conserved ID of taxa from blast.txt .
        python sort_blasted_seq.py -i ${COMPLETE_BLAST_PATH}/$interest_blast \
               -o ${basename_}conserved.txt \
               -n /data2/home/masalm/.etetoolkit/taxa.sqlite
    done
    echo "sort_blasted_seq.py Done"

    #cat ${COMPLETE_BLAST_PATH}/${conserved} |awk -v pathF="${COMPLETE_BLAST_PATH}/${basename_fasta}" -F"[\t]" '\''$10~/^1/ {print $1" "$8 > pathF"/map1.fa" ; print $1 > pathF"/1.fa" }'\'
    #cat ${COMPLETE_BLAST_PATH}/${conserved} |awk -v pathF="${COMPLETE_BLAST_PATH}/${basename_fasta}" -F"[\t]" '\''$10~/^2/ {print $1" "$8 > pathF"/map2.fa" ; print $1 > pathF"/2.fa"}'\'
    #./RecoverReads.sh ${COMPLETE_BLAST_PATH}/${basename_fasta}/1.fa ${folderInput}/${clseqs1} empty.txt ${COMPLETE_BLAST_PATH}/${basename_fasta}/1.fasta
    #./RecoverReads.sh ${COMPLETE_BLAST_PATH}/${basename_fasta}/2.fa ${folderInput}/${clseqs2} empty.txt ${COMPLETE_BLAST_PATH}/${basename_fasta}/2.fasta
    #cat ${COMPLETE_BLAST_PATH}/${basename_fasta}/1.fasta | paste - - | cut -c2- |sort > ${COMPLETE_BLAST_PATH}/${basename_fasta}/sorted1.fasta
    #cat ${COMPLETE_BLAST_PATH}/${basename_fasta}/2.fasta | paste - - | cut -c2- |sort > ${COMPLETE_BLAST_PATH}/${basename_fasta}/sorted2.fasta
    #sort ${COMPLETE_BLAST_PATH}/${basename_fasta}/map1.fa > ${COMPLETE_BLAST_PATH}/${basename_fasta}/sorted1.fa
    #sort ${COMPLETE_BLAST_PATH}/${basename_fasta}/map2.fa > ${COMPLETE_BLAST_PATH}/${basename_fasta}/sorted2.fa
    #join -11 -21 ${COMPLETE_BLAST_PATH}/${basename_fasta}/sorted1.fasta ${COMPLETE_BLAST_PATH}/${basename_fasta}/sorted1.fa > ${COMPLETE_BLAST_PATH}/${basename_fasta}/1.fasta
    #join -11 -21 ${COMPLETE_BLAST_PATH}/${basename_fasta}/sorted2.fasta ${COMPLETE_BLAST_PATH}/${basename_fasta}/sorted2.fa > ${COMPLETE_BLAST_PATH}/${basename_fasta}/2.fasta
    #cat ${COMPLETE_BLAST_PATH}/${basename_fasta}/1.fasta |awk -v pathF="${COMPLETE_BLAST_PATH}/${basename_fasta}" '\''{print ">"$1" "$2" "$3"\n"$4 > pathF"/"$5".fasta"}'\'
    #cat ${COMPLETE_BLAST_PATH}/${basename_fasta}/2.fasta |awk -v pathF="${COMPLETE_BLAST_PATH}/${basename_fasta}" '\''{print ">"$1" "$2" "$3"\n"$4 >> pathF"/"$5".fasta"}'\'
    #rm ${COMPLETE_BLAST_PATH}/${basename_fasta}/1.fasta ${COMPLETE_BLAST_PATH}/${basename_fasta}/2.fasta ${COMPLETE_BLAST_PATH}/${basename_fasta}/1.fa ${COMPLETE_BLAST_PATH}/${basename_fasta}/2.fa
    #rm ${COMPLETE_BLAST_PATH}/${basename_fasta}/map1.fa ${COMPLETE_BLAST_PATH}/${basename_fasta}/map2.fa ${COMPLETE_BLAST_PATH}/${basename_fasta}/sorted1.fa ${COMPLETE_BLAST_PATH}/${basename_fasta}/sorted2.fa
    #rm ${COMPLETE_BLAST_PATH}/${basename_fasta}/sorted1.fasta ${COMPLETE_BLAST_PATH}/${basename_fasta}/sorted2.fasta
    #find ${COMPLETE_BLAST_PATH}/${basename_fasta} -type f |
    #    while read f; do
    #        i=0
    #        while read line; do
    #            i=$((i+1))
    #            [ $i -eq 10 ] && continue 2
    #        done < "$f"
    #        printf %s\\n "$f"
    #    done |
    #    xargs rm -f
    #sort -n ${COMPLETE_BLAST_PATH}/${conserved} -k8,8 > ${COMPLETE_BLAST_PATH}/{}sorted.txt
    #rm ${COMPLETE_BLAST_PATH}/${conserved}
    #mv ${COMPLETE_BLAST_PATH}/{}sorted.txt ${COMPLETE_BLAST_PATH}/${conserved}
    #cut -f8 ${COMPLETE_BLAST_PATH}/${conserved} | uniq -c |sort -k2,2 -g > ${COMPLETE_BLAST_PATH}/${temp1}
    #cut -f2,8 ${COMPLETE_BLAST_PATH}/${conserved} | sort -k1 | uniq | cut -f2 | sort -g | uniq -c > ${COMPLETE_BLAST_PATH}/${temp2}
    #join -1 2 -2 2 ${COMPLETE_BLAST_PATH}/${temp1} ${COMPLETE_BLAST_PATH}/${temp2} |sort -k1,1b > ${COMPLETE_BLAST_PATH}/${temp3}
    #join -1 1 -2 1 ${COMPLETE_BLAST_PATH}/${temp3} /data2/home/masalm/Antoine/DB/MetaPhlAn/totalCountofGenes.txt | sort -k2,2 -gr > ${COMPLETE_BLAST_PATH}/${counting}
    #./getNames.py ${COMPLETE_BLAST_PATH}/${counting}
    #rm ${COMPLETE_BLAST_PATH}/${counting}
    #rm ${COMPLETE_BLAST_PATH}/${temp1} ${COMPLETE_BLAST_PATH}/${temp2} ${COMPLETE_BLAST_PATH}/${temp3}
else
    echo "Bacteria directory doesn't exists."
fi

# Deactivate conda environment.
source deactivate
