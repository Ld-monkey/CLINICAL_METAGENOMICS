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
# e.g :
# bash find_same_id_kraken_blast_bacteria.sh \
#      -path_taxo ../../results/test/bacteria_reads_clean_fda_refseq_human_viral_07_05_2020/ \
#      -path_blast ../../results/test/bacteria_metaphlan_blast_clean_fda_refseq_human_viral_07_05_2020/ \
#      -path_clseq ../../results/test/bacteria_classified_reads_clean_fda_refseq_human_viral_07_05_2020 \
#      -path_ncbi ../../data/databases/ete3_ncbi_taxanomy_database_05_05_2020/

# Function to remove all intermediate files
function remove_all_intermediate_files {

    # Remove #.fasta and #.fa files.
    rm ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/1.fasta \
       ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/2.fasta \
       ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/1.fasta \
       ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/2.fasta

    # Remove map#.fa and sorted#.fa.
    rm ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/map1.fasta \
       ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/map2.fasta \
       ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/sorted1.fasta \
       ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/sorted2.fasta

    # Finally remove the folder.
    rm ${BLAST_FOLDER}/${NAME_BLAST_TO_CONSERVED}
}

PROGRAM=find_same_id_kraken_blast_bacteria.sh
VERSION=1.0

DESCRIPTION=$(cat << __DESCRIPTION__

__DESCRIPTION__
           )

OPTIONS=$(cat << __OPTIONS__

## OPTIONS ##
    -path_taxo       (Input)  The path of folder with Bacteria or Viruses or (Fongi) folders               *DIR: input_bacteria_folder
    -path_blast      (Input)  The folder of the blast results containing .blast.txt                        *DIR: input_results_blast
    -path_clseq      (Input)  The folder of classified sequences containing .clseqs_                       *DIR: input_classified_folder
    -path_ncbi       (Input)  The folder of ncbi taxonomy containing .taxa.sqlite                          *DIR: input_blast_taxa_db
__OPTIONS__
       )

# default options if they are not defined:
default_path_ncbi=~/.etetoolkit/

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
    echo "example : find_same_id_kraken_blast_bacteria.sh \
                    -path_taxo ../../results/test/bacteria_reads_clean_fda_refseq_human_viral_07_05_2020/ \
                    -path_blast ../../results/test/bacteria_metaphlan_blast_clean_fda_refseq_human_viral_07_05_2020/ \
                    -path_clseq ../../results/test/bacteria_classified_reads_clean_fda_refseq_human_viral_07_05_2020 \
                    -path_ncbi ../../data/databases/ete3_ncbi_taxanomy_database_05_05_2020"
    echo -e $USAGE

    exit 1
}

# Check options
while [ -n "$1" ]; do
    case $1 in
        -h)                    USAGE      ; exit 0 ;;
  	    -path_taxo)           FOLDER_TAXO=$2       ; shift 2; continue ;;
        -path_blast)          BLAST_FOLDER=$2      ; shift 2; continue ;;
        -path_clseq)          CLASSIFIED_FOLDER=$2 ; shift 2; continue ;;
        -path_ncbi)           PATH_NCBI_TAXA=$2    ; shift 2; continue ;;
        *)       BAD_OPTION $1;;
    esac
done

#FOLDER_VIRUSES=$FOLDER_TAXO/Viruses
FOLDER_BACTERIA=$FOLDER_TAXO

# Export the variable of path folder in current terminal.
export FOLDER_TAXO
#export FOLDER_VIRUSES
export FOLDER_BACTERIA

# Check if blast folder exists.
if [ -d $BLAST_FOLDER ]
then
    echo "Blast folder $BLAST_FOLDER exists."
else
    echo "Error : $BLAST_FOLDER doesn't exists."
    exit
fi

# Check if classified folder exists.
if [ -d $CLASSIFIED_FOLDER ]; then
    echo "Classified folder $CLASSIFIED_FOLDER is loaded"
else
    echo "No classified folder is found."
fi

# Check if ncbi taxonomy database exists.
if [ -d $PATH_NCBI_TAXA ]; then
    echo "NCBI taxonomy db $PATH_NCBI_TAXA is loaded"
else
    echo "No ncbi taxonomy database folder is found."
    PATH_NCBI_TAXA=$default_path_ncbi
fi

# Begin a parallel task for Bacteria.
if [ -d $FOLDER_BACTERIA ]
then

    echo "Path : $BLAST_FOLDER"
    echo "####################Check Done !######################"

    # Get all blast files (*.blast) for bacteria.
    BLAST_FILES=$(ls $BLAST_FOLDER | grep -i blast)
    echo -e "Blast files for Bacteria are : \n$BLAST_FILES"

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
        # python ../python/sort_blasted_seq.py \
        #        -i ${BLAST_FOLDER}$EACH_BLAST_FILE \
        #        -o ${BASENAME_FILE}conserved.txt \
        #        -n ${PATH_NCBI_TAXA}taxa.sqlite
    done
    echo "sort_blasted_seq.py Done"

    echo "#################### Conserved sequences !###################"
    # Change name variable *.blast.txt to *conserved.txt .
    NAME_BLAST_TO_CONSERVED=$(echo -e "\n$BLAST_FILES" | sed "s/.blast.txt/conserved.txt/g")
    echo "conserved : $NAME_BLAST_TO_CONSERVED"
 
    # From conserved file extract id and create 1.fa 2.fa map1.fa and map2.fa .
    for file in $NAME_BLAST_TO_FASTA
    do

        #echo $file
        #echo $(echo "$file" | sed "s/_fasta/_conserved.txt/g")
        open_file=${BLAST_FOLDER}${file}/$(echo "$file" | sed "s/_fasta/_conserved.txt/g")
        #echo $open_file

        #awk -F "[\t]" -v path=${BLAST_FOLDER}$file '$10~/^1/ {print $1" "$8 > path"/map1.fa" ; print $1 > path"/1.fa"}' $open_file
        echo "map1.fa and 1.fa were created for $open_file"

        #awk -F "[\t]" -v path=${BLAST_FOLDER}$file '$10~/^2/ {print $1" "$8 > path"/map2.fa" ; print $1 > path"/2.fa"}' $open_file
        echo "map2.fa and 2.fa were created for $open_file"
    done
    echo "#############################################################"

    echo "#################### Recover reads !########################"
    for file in $BLAST_FILES
    do
        # Change name variable *.blast.txt to *clseqs_*.fastq .
        CLASSIFIED_SEQ_1=$(echo "$file" | sed "s/blast.txt/clseqs_1.fastq/g")
        CLASSIFIED_SEQ_2=$(echo "$file" | sed "s/blast.txt/clseqs_2.fastq/g")

        open_file=${BLAST_FOLDER}$(echo "$file" | sed "s/.blast.txt/fasta/g")

        echo $open_file
   
        # bash recover_reads.sh \
        #      -reads_list ${open_file}/1.fa \
        #      -clseqs_1 $CLASSIFIED_FOLDER${CLASSIFIED_SEQ_1}\
        #      -output ${open_file}/1.fasta

        echo "1.fasta is created !"

        # bash recover_reads.sh \
        #      -reads_list ${open_file}/2.fa \
        #      -clseqs_1 $CLASSIFIED_FOLDER${CLASSIFIED_SEQ_2}\
        #      -output ${open_file}/2.fasta

        echo "2.fasta is created !"
    done
    echo "done recover reads !"

    # Create the fasta sorted files.
    # paste : delete the line break between the characteristic line
    # and the nucleotide lines.
    # cut : remove '>' in fasta file.
    # e.g :
    # >NB552188:4:H353CBGXC:1:22211:5250:17917 1:N:0:1 kraken:taxid|573
    # CAGGAAAAGGCGCTCCCGCAGCCAAGCACATCTATTTTCATTTACCCTCGCCAAAATTTTTTGCC
    # to :
    #>NB552188:4:H353CBGXC:1:22211:5250:17917 1:N:0:1 kraken:taxid|573       CAGG...
    cat ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/1.fasta \
        | paste - - \
        |cut -c2- \
        |sort > ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/sorted1.fasta

    cat ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/2.fasta \
        | paste - - \
        | cut -c2- \
        | sort > ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/sorted2.fasta

    # BECAREFUL : CREATE BOTH TIME sorted#.fasta. 
    # Sort map1 and map2 and get outputs sorted1.fa and sorted2.fa
    # before joining else join command bug.
    sort ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/map1.fa \
         --output ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/sorted1.fa

    sort ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/map2.fa \
         --output ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/sorted2.fa

    # Join the same sorted#.fasta file to create again the 1.fasta WHY ?
    # Result of this step :
    # before :
    # >NB552188:4:H353CBGXC:1:22211:5250:17917 1:N:0:1 kraken:taxid|573       CAGGA....A
    # after :
    # >NB552188:4:H353CBGXC:1:22211:5250:17917 1:N:0:1 kraken:taxid|573 CAGGA....A 1:N:0:1 kraken:taxid|573 CAGGA...A
    # Create both time output #.fa WHY ?
    join -1 1 -2 1 ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/sorted1.fasta \
         ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/sorted1.fa \
         > ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/1.fasta

    join -1 1 -2 1 ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/sorted2.fasta \
         ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/sorted2.fa \
         > ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/2.fasta

    # ??? Maybe create new .fasta with ??? nucleotide sequence ??
    # e.g : awk -F "[\t]" -v path=${BLAST_FOLDER}$file '$10~/^1/ {print $1" "$8 > path"/map1.fa" ; print $1 > path"/1.fa"}' $open_file
    awk -v path=${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA} '{print ">"$1" "$2" "$3"\n"$4 > pathF"/"$5".fasta"}' ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/1.fasta
    awk -v path=${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA} '{print ">"$1" "$2" "$3"\n"$4 > pathF"/"$5".fasta"}' ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA}/2.fasta

    # WTF men !
    find ${BLAST_FOLDER}/${NAME_BLAST_TO_FASTA} -type f |
        while read f; do
            i=0
            while read line; do
                i=$((i+1))
                [ $i -eq 10 ] && continue 2
            done < "$f"
            printf %s\\n "$f"
        done |
        xargs rm -f
 
    find bacteria_metaphlan_blast_clean_fda_refseq_human_viral_07_05_2020 -type f |
        while read f; do
            i=0
            while read line; do
                i=$((i+1))
                [ $i -eq 10 ] && continue 2
            done < "$f"
            printf %s "$f"
        done

    # 
    # sort -n ${BLAST_FOLDER}/${NAME_BLAST_TO_CONSERVED} -k8,8 \
    #      --output ${BLAST_FOLDER}/{}sorted.txt

    #
    mv ${BLAST_FOLDER}/{}sorted.txt ${BLAST_FOLDER}/${NAME_BLAST_TO_CONSERVED}


    # # Change variable blast.txt to temps*.txt .
    temp1=$(echo $BLAST_FILES | sed "s/blast.txt/temp1.txt/g")
    temp2=$(echo $BLAST_FILES | sed "s/blast.txt/temp2.txt/g")
    temp3=$(echo $BLAST_FILES | sed "s/blast.txt/temp3.txt/g")

    echo "temp1 : $temp1"
    echo "temp2 : $temp2"
    echo "temp3 : $temp3"

    # 
    # cut -f8 ${BLAST_FOLDER}/${NAME_BLAST_TO_CONSERVED} | uniq -c | sort -k2,2 -g > ${BLAST_FOLDER}/${temp1}
    # cut -f2,8 ${BLAST_FOLDER}/${NAME_BLAST_TO_CONSERVED} | sort -k1 | uniq | cut -f2 | sort -g | uniq -c > ${BLAST_FOLDER}/${temp2}

    # 
    # join -1 2 -2 2 ${BLAST_FOLDER}/${temp1} ${BLAST_FOLDER}/${temp2} | sort -k1,1b > ${BLAST_FOLDER}/${temp3}
    # join -1 1 -2 1 ${BLAST_FOLDER}/${temp3} /data2/home/masalm/Antoine/DB/MetaPhlAn/totalCountofGenes.txt | sort -k2,2 -gr > ${BLAST_FOLDER}/${counting}

    # 
    # python ../python/get_names.py ${BLAST_FOLDER}/${counting}

    #
    # rm ${BLAST_FOLDER}/${counting}
    # rm ${BLAST_FOLDER}/${temp1} ${BLAST_FOLDER}/${temp2} ${BLAST_FOLDER}/${temp3}

    # Counting variable change blast.txt to counting.txt .
    # counting=$(echo $BLAST_FILES | sed "s/blast.txt/countbis.txt/g")

    echo "counting : $counting"

    # Remove intermediate files.
    remove_all_intermediate_files
else
    echo "Bacteria directory doesn't exists."
fi
