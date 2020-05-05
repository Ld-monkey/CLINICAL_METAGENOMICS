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
# e.g ./find_same_id_kraken_blast.sh \
# -path_taxo output_preprocess_reads_clean_FDA_refseq_human_viral \
# -path_blast METAPHLAN_BLAST_TEST
# -path_ncbi ../../data/databases/ete3_ncbi_taxanomy_database_05_05_2020

PROGRAM=find_same_id_kraken_blast.sh
VERSION=1.0

DESCRIPTION=$(cat << __DESCRIPTION__

__DESCRIPTION__
           )

OPTIONS=$(cat << __OPTIONS__

## OPTIONS ##
    -path_taxo       (Input)  The path of folder with Bacteria or Viruses or (Fongi) folders               *DIR: input_bacteria_folder
    -path_blast      (Input)  The folder of the blast results containing .blast.txt                        *DIR: input_results_blast
    -path_ncbi       (Input)  The folder of ncbi taxonomy containing .taxa.sqlite                          *DIR: input_blast_taxa_db                
__OPTIONS__
       )

# default options if they are not defined:
default_path_ncbi=../../data/NCBITaxa/

USAGE ()
{
    cat << __USAGE__
$PROGRAM version $VERSION:
$DESCRIPTION
$OPTIONS

__USAGE__
}

BAD_OPTION ()
{
    echo
    echo "Unknown option "$1" found on command-line"
    echo "It may be a good idea to read the usage:"
    echo "white $PROGRAM -h to be helped :"
    echo "example : ./find_same_id_kraken_blast.sh"
    echo -e $USAGE

    exit 1
}

# Check options
while [ -n "$1" ]; do
    case $1 in
        -h)                    USAGE      ; exit 0 ;;
  	    -path_taxo)           FOLDER_TAXO=$2   ; shift 2; continue ;;
        -path_blast)          BLAST_FOLDER=$2  ; shift 2; continue ;;
        -path_ncbi)           PATH_NCBI_TAXA=$2; shift 2; continue ;;         
        *)       BAD_OPTION $1;;
    esac
done

FOLDER_VIRUSES=$FOLDER_TAXO/Viruses
FOLDER_BACTERIA=$FOLDER_TAXO/Bacteria

# Export the variable of path folder in current terminal.
export FOLDER_TAXO
export FOLDER_VIRUSES
export FOLDER_BACTERIA

# Check if ncbi taxonomy database exists.
if [ -d $PATH_NCBI_TAXA ]; then
    echo "$PATH_NCBI_TAXA is loaded"
else
    echo "No ncbi taxonomy database folder is found."
    PATH_NCBI_TAXA=$default_path_ncbi
fi

# Begin a parallel task for Bacteria.
if [ -d $FOLDER_BACTERIA ]
then

    # Check if blast folder exists.
    if [ -d $BLAST_FOLDER ]
    then
        echo "$BLAST_FOLDER exists."
    else
        echo "Error : $BLAST_FOLDER doesn't exists."
        exit
    fi

    echo "Path : $BLAST_FOLDER"

    # Get all blast files (*.blast) for bacteria.
    BLAST_FILES=$(ls $BLAST_FOLDER | grep -i blast)
    echo "Blast files for Bacteria are : $BLAST_FILES"

    # Classified sequences change blast.txt to clseqs_*.fastq .
    clseqs1=$(echo $BLAST_FILES | sed "s/blast.txt/clseqs_1.fastq/g")
    clseqs2=$(echo $BLAST_FILES | sed "s/blast.txt/clseqs_2.fastq/g")

    echo "clseqs1 : $clseqs1"
    echo "clseqs2 : $clseqs2"

    # Conserved variable change blast.txt to conserved.txt .
    conserved=$(echo $BLAST_FILES | sed "s/blast.txt/conserved.txt/g")

    echo "conserved : $conserved"

    # Counting variable change blast.txt to counting.txt .
    counting=$(echo $BLAST_FILES | sed "s/blast.txt/countbis.txt/g")

    echo "counting : $counting"

    # Change variable blast.txt to temps*.txt .
    temp1=$(echo $BLAST_FILES | sed "s/blast.txt/temp1.txt/g")
    temp2=$(echo $BLAST_FILES | sed "s/blast.txt/temp2.txt/g")
    temp3=$(echo $BLAST_FILES | sed "s/blast.txt/temp3.txt/g")

    echo "temp1 : $temp1"
    echo "temp2 : $temp2"
    echo "temp3 : $temp3"

    # Change name variable *.blast.txt to *fasta
    basename_fasta=$(echo $BLAST_FILES | sed "s/.blast.txt/fasta/g")

    # For each sample create folder with result.
    for folder_to_create in $basename_fasta
    do
        echo "Create $BLAST_FOLDER/$folder_to_create directory."
        mkdir -p ${BLAST_FOLDER}/$folder_to_create
        echo "Create $BLAST_FOLDER/$folder_to_create done."
    done

    # 3 parameters :
    # -i : The blast file input e.g *.blast.txt .
    # -o : The output file for e.g *_conserved.txt .
    # -n : The localization of NCBI taxa database.
    echo "run sort_blasted_seq.py"
    echo "BLAST_FOLDER : $BLAST_FOLDER"
    for interest_blast in $BLAST_FILES/*blast.txt
    do
        echo "File used in sort_blasted_seq.py is : ${BLAST_FOLDER}/$interest_blast "
        echo "$interest_blast"
        basename_=$(basename "$interest_blast" .blast.txt)
        echo "Basename : $basename_"

        # Output files is conserved and not_conserved ID of taxa from blast.txt .
        python ../python/sort_blasted_seq.py \
               -i ${BLAST_FOLDER}/$interest_blast \
               -o ${basename_}conserved.txt \
               -n ${PATH_NCBI_TAXA}/taxa.sqlite
    done
    echo "sort_blasted_seq.py Done"

    # Part of the code that I really don't understand.
    cat ${FOLDER_TAXO}/${conserved} | awk -v pathF="${BLAST_FOLDER}/${basename_fasta}" \
                                          -F "[\t]" '\''$10~/^1/ {print $1" "$8 > pathF"/map1.fa" ; print $1 > pathF"/1.fa" }'\'
    cat ${BLAST_FOLDER}/${conserved} | awk -v pathF="${BLAST_FOLDER}/${basename_fasta}" \
                                           -F"[\t]" '\''$10~/^2/ {print $1" "$8 > pathF"/map2.fa" ; print $1 > pathF"/2.fa"}'\'

    # They is no -clseqs_2 parameter ???
    # I don't understand again.
    bash recover_reads.sh \
         -reads_list ${folderInput}/${clseqs1} empty.txt \
         -clseqs_1 ${BLAST_FOLDER}/${basename_fasta}/1.fa \
         -output ${BLAST_FOLDER}/${basename_fasta}/1.fasta

    bash recover_reads.sh \
         -reads_list ${folderInput}/${clseqs2} empty.txt \
         -clseqs_1 ${BLAST_FOLDER}/${basename_fasta}/2.fa \
         -output ${BLAST_FOLDER}/${basename_fasta}/2.fasta

    # I don't know WTF.
    cat ${BLAST_FOLDER}/${basename_fasta}/1.fasta | paste - - | cut -c2- | sort > ${BLAST_FOLDER}/${basename_fasta}/sorted1.fasta
    cat ${BLAST_FOLDER}/${basename_fasta}/2.fasta | paste - - | cut -c2- | sort > ${BLAST_FOLDER}/${basename_fasta}/sorted2.fasta

    # Sort map1 and map2 and get sorted1 and sorted2.fa
    sort ${BLAST_FOLDER}/${basename_fasta}/map1.fa \
         --output ${BLAST_FOLDER}/${basename_fasta}/sorted1.fa
    sort ${BLAST_FOLDER}/${basename_fasta}/map2.fa \
         --output ${BLAST_FOLDER}/${basename_fasta}/sorted2.fa

    # Join something.
    join -11 -21 ${BLAST_FOLDER}/${basename_fasta}/sorted1.fasta ${BLAST_FOLDER}/${basename_fasta}/sorted1.fa > ${BLAST_FOLDER}/${basename_fasta}/1.fasta
    join -11 -21 ${BLAST_FOLDER}/${basename_fasta}/sorted2.fasta ${BLAST_FOLDER}/${basename_fasta}/sorted2.fa > ${BLAST_FOLDER}/${basename_fasta}/2.fasta

    #
    cat ${BLAST_FOLDER}/${basename_fasta}/1.fasta |awk -v pathF="${BLAST_FOLDER}/${basename_fasta}" '\''{print ">"$1" "$2" "$3"\n"$4 > pathF"/"$5".fasta"}'\'
    cat ${BLAST_FOLDER}/${basename_fasta}/2.fasta |awk -v pathF="${BLAST_FOLDER}/${basename_fasta}" '\''{print ">"$1" "$2" "$3"\n"$4 >> pathF"/"$5".fasta"}'\'

    # Remove
    rm ${BLAST_FOLDER}/${basename_fasta}/1.fasta \
       ${BLAST_FOLDER}/${basename_fasta}/2.fasta \
       ${BLAST_FOLDER}/${basename_fasta}/1.fa \
       ${BLAST_FOLDER}/${basename_fasta}/2.fa

    rm ${BLAST_FOLDER}/${basename_fasta}/map1.fa \
       ${BLAST_FOLDER}/${basename_fasta}/map2.fa \
       ${BLAST_FOLDER}/${basename_fasta}/sorted1.fa \
       ${BLAST_FOLDER}/${basename_fasta}/sorted2.fa

    rm ${BLAST_FOLDER}/${basename_fasta}/sorted1.fasta \
       ${BLAST_FOLDER}/${basename_fasta}/sorted2.fasta

    # WTF men !
    find ${BLAST_FOLDER}/${basename_fasta} -type f |
        while read f; do
            i=0
            while read line; do
                i=$((i+1))
                [ $i -eq 10 ] && continue 2
            done < "$f"
            printf %s\\n "$f"
        done |
        xargs rm -f

    #
    sort -n ${BLAST_FOLDER}/${conserved} -k8,8 > ${BLAST_FOLDER}/{}sorted.txt

    #
    rm ${BLAST_FOLDER}/${conserved}

    #
    mv ${BLAST_FOLDER}/{}sorted.txt ${BLAST_FOLDER}/${conserved}

    #
    cut -f8 ${BLAST_FOLDER}/${conserved} | uniq -c | sort -k2,2 -g > ${BLAST_FOLDER}/${temp1}
    cut -f2,8 ${BLAST_FOLDER}/${conserved} | sort -k1 | uniq | cut -f2 | sort -g | uniq -c > ${BLAST_FOLDER}/${temp2}

    #
    join -1 2 -2 2 ${BLAST_FOLDER}/${temp1} ${BLAST_FOLDER}/${temp2} |sort -k1,1b > ${BLAST_FOLDER}/${temp3}
    join -1 1 -2 1 ${BLAST_FOLDER}/${temp3} /data2/home/masalm/Antoine/DB/MetaPhlAn/totalCountofGenes.txt | sort -k2,2 -gr > ${BLAST_FOLDER}/${counting}

    #
    python ../python/get_names.py ${BLAST_FOLDER}/${counting}

    #
    rm ${BLAST_FOLDER}/${counting}
    rm ${BLAST_FOLDER}/${temp1} ${BLAST_FOLDER}/${temp2} ${BLAST_FOLDER}/${temp3}
else
    echo "Bacteria directory doesn't exists."
fi


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

# Deactivate conda environment.
conda deactivate
