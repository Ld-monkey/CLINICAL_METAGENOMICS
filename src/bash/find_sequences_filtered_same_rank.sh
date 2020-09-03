#!/bin/bash

# find the sequences filtered according to the same rank.
# e.g bash bash src/bash/
# bash src/bash/find_sequences_filtered_same_rank.sh \
#     -path_classified results/30_08_2020_20h_56m_49s/kraken2_classification/1-MAR-LBA-ADN_S1/classified/ \
#     -path_conserved results/30_08_2020_20h_56m_49s/same_taxonomics_id_kraken_blast/conserved.txt \
#     -path_output results/30_08_2020_20h_56m_49s/filtered_sequences/


# Display all informations about paramaters.
function display_informations {

    echo "Kraken2 classification : $KRAKEN_CLASSIFICATION"
    echo "conserved seq : $CONSERVED_SEQUENCES"
    echo "output folder : $FOLDER_OUTPUT"
}


# Function to check if the output folder is set.
function check_output_folder {

    # Check if parameter is set.
    if [ -z ${FOLDER_OUTPUT+x} ]; then
        echo "-path_output is unset"
        echo "You must specify the -path_output parameter"
        echo "exit"
        exit 1
    else
        echo "-path_output is set"

        # Create the output folder.
        mkdir -p --verbose $FOLDER_OUTPUT
    fi
}


# Create sequences with names in file name.lst, one sequence name per line.
function create_sequences_name_list_file {
    
    awk -F "[\t]" -v path=$FOLDER_OUTPUT \
	'$10~/^1/ {print $1 > path"/1.lst"}' $CONSERVED_SEQUENCES

    echo "1.lst is created"

    awk -F "[\t]" -v path=$FOLDER_OUTPUT \
	'$10~/^2/ {print $1 > path"/2.lst"}' $CONSERVED_SEQUENCES

    echo "2.lst is created"

}


# Recovers sequences from original classified Kraken 2 sequences.
function recover_specific_sequences_from_kraken_classification {
    
    CLASSIFIED_FASTQ1=$(ls ${KRAKEN_CLASSIFICATION}*clseqs_1*)
    CLASSIFIED_FASTQ2=$(ls ${KRAKEN_CLASSIFICATION}*clseqs_2*)

    echo "clseqs_1 : $CLASSIFIED_FASTQ1"
    echo "clseqs_2 : $CLASSIFIED_FASTQ2"

    # Recovers classified first paired reads.
    bash src/bash/convert_fastq_to_fasta.sh \
	 -path_fastq_1 $CLASSIFIED_FASTQ1 \
	 -path_list ${FOLDER_OUTPUT}1.lst \
	 -output_fasta ${FOLDER_OUTPUT}1.fasta

    echo "1.fasta is created"

    # Recovers classified seconde paired reads.
    bash src/bash/convert_fastq_to_fasta.sh \
	 -path_fastq_1 $CLASSIFIED_FASTQ2 \
	 -path_list $FOLDER_OUTPUT/2.lst\
	 -output_fasta ${FOLDER_OUTPUT}2.fasta

    echo "2.fasta is created"
}


# Sorted filtered and classified sequences.
function sort_filtered_classified_sequences {

    cat ${FOLDER_OUTPUT}1.fasta \
	| paste - - | cut -c2- \
	| sort > ${FOLDER_OUTPUT}sorted1.fasta

    echo "sorted1.fasta is created"

    cat ${FOLDER_OUTPUT}2.fasta \
	| paste - - | cut -c2- \
	| sort > ${FOLDER_OUTPUT}sorted2.fasta

    echo "sorted2.fasta is created"
}


# Create sequences with names in file name.lst, one sequence name per line.
function create_mapping_name_list_file {
    
    awk -F "[\t]" -v path=$FOLDER_OUTPUT \
	'$10~/^1/ {print $1" "$8 > path"/map1.lst"}' $CONSERVED_SEQUENCES

    echo "map1.lst is created"

    awk -F "[\t]" -v path=$FOLDER_OUTPUT \
	'$10~/^2/ {print $1" "$8 > path"/map2.lst"}' $CONSERVED_SEQUENCES

    echo "map2.lst is created"

}


# Sort map1.lst and map2.lst .
function sort_map_classified_sequences {

    echo "Warning they are a different beewteen sorted.fa and sorted.fasta "

    sort ${FOLDER_OUTPUT}map1.lst \
         --output ${FOLDER_OUTPUT}sorted1.fa

    echo "sorted1.fa is created (!=sorted1.fasta)"

    sort ${FOLDER_OUTPUT}map2.lst \
         --output ${FOLDER_OUTPUT}sorted2.fa

    echo "sorted2.fa is created (!=sorted2.fasta)"
}


# Joining results.
function joining_sorted_informations {

    join -1 1 -2 1 ${FOLDER_OUTPUT}sorted1.fasta \
         ${FOLDER_OUTPUT}sorted1.fa \
         > ${FOLDER_OUTPUT}1.fasta

    echo "Joining and overwhite 1.fasta"

    join -1 1 -2 1 ${FOLDER_OUTPUT}sorted2.fasta \
         ${FOLDER_OUTPUT}sorted2.fa \
         > ${FOLDER_OUTPUT}2.fasta

    echo "Joining and overwhite 2.fasta"
}


# Extract all the sequences according to their taxonomic
# similarities and create the corresponding fasta files.
function extract_sequences_into_fasta_files {
    
    awk -v path=${FOLDER_OUTPUT} \
	'{print ">"$1" "$2" "$3"\n"$4 > path"/"$5".fasta"}' ${FOLDER_OUTPUT}1.fasta

    echo "Create and overwhite 1.fasta"
    
    awk -v path=${FOLDER_OUTPUT} \
	'{print ">"$1" "$2" "$3"\n"$4 > path"/"$5".fasta"}' ${FOLDER_OUTPUT}2.fasta

    echo "Create and overwhite 2.fasta"
}


# # Remove intermediate files.
# function remove_intermediate_files {
#     rm -rf --verbose ${FOLDER_OUTPUT}1.fasta
#     rm -rf --verbose ${FOLDER_OUTPUT}2.fasta
#     rm -rf --verbose ${FOLDER_OUTPUT}1.fa
#     rm -rf --verbose ${FOLDER_OUTPUT}2.fa
#     rm -rf --verbose ${FOLDER_OUTPUT}map1.lst
#     rm -rf --verbose ${FOLDER_OUTPUT}map2.lst
#     rm -rf --verbose ${FOLDER_OUTPUT}sorted1.fa
#     rm -rf --verbose ${FOLDER_OUTPUT}sorted2.fa
#     rm -rf --verbose ${FOLDER_OUTPUT}sorted1.fasta
#     rm -rf --verbose ${FOLDER_OUTPUT}sorted2.fasta
# }


# Delete results with less than 10 sequences.
function delete_results_less_10_sequences {

    echo ${FOLDER_OUTPUT}taxon_removed.txt

    find $FOLDER_OUTPUT -type f |
        while read f; do
            i=0
            while read line; do
                i=$((i+1))
                [ $i -eq 10 ] && continue 2
            done < "$f"
            printf %s\\n "$f"
        done |
        xargs rm -f --verbose
}

PROGRAM=find_sequences_filtered_same_rank.sh
VERSION=1.0

DESCRIPTION=$(cat << __DESCRIPTION__

__DESCRIPTION__
           )

OPTIONS=$(cat << __OPTIONS__

## OPTIONS ##
    -path_classified (Input) Path of classified Kraken 2 folder with fasta sequences.
    	    *DIR: classified_kraken2/
    -path_conserved  (Input) Path of conserved sequences in fasta or txt file.                                *STR: conserved.txt 
    -path_output     (Output)
__OPTIONS__
       )

# default options:

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
    echo ""
    echo -e $USAGE

    exit 1
}

# Check options
while [ -n "$1" ]; do
    case $1 in
	-h)                    USAGE      ; exit 0 ;;
	-path_classified)      KRAKEN_CLASSIFICATION=$2 ; shift 2; continue ;;
	-path_conserved)       CONSERVED_SEQUENCES=$2   ; shift 2; continue ;;
	-path_output)          FOLDER_OUTPUT=$2         ; shift 2; continue ;;
        *)       BAD_OPTION $1;;
    esac
done


# Display all informations.
display_informations

# Create output folder.
check_output_folder

# Get the path folder.
CONSERVED_SEQ_FOLDER=$(dirname $CONSERVED_SEQUENCES)

echo "conserved sequence folder name is : $CONSERVED_SEQ_FOLDER"

# Extract sequences with names in file.
create_sequences_name_list_file

# Recovers sequences from original classified Kraken 2 sequences.
recover_specific_sequences_from_kraken_classification

# Sorted filtered and classified sequences.
sort_filtered_classified_sequences

# Extract map.
create_mapping_name_list_file

# Sort map1.lst and map2.lst .
sort_map_classified_sequences

# Joining results.
joining_sorted_informations

# Create all fasta.
extract_sequences_into_fasta_files

# Remove intermediate files.
#remove_intermediate_files

# Delete results with less than 10 sequences.
delete_results_less_10_sequences

# Sort conserved classified blast.
sort -n $CONSERVED_SEQUENCES -k8,8 \
     --output ${CONSERVED_SEQ_FOLDER}/conserved_sorted.txt

echo "conserved_sorted.txt is created"

# select the taxon id and count for each taxon.
cut -f8 ${CONSERVED_SEQ_FOLDER}/conserved_sorted.txt \
    | uniq -c > ${CONSERVED_SEQ_FOLDER}/conserved_sorted_temp1.txt

echo "conserved_sorted_temp1.txt is created"

#
cut -f8 ${CONSERVED_SEQ_FOLDER}/conserved_sorted.txt \
    | uniq > ${CONSERVED_SEQ_FOLDER}/conserved_sorted_temp2.txt

echo "conserved_sorted_temp2.txt is created"

# From conserved_sorted_temp2.txt
while read p; do
    echo "p: $p"
    echo -n $p" " >> ${CONSERVED_SEQ_FOLDER}/conserved_sorted_temp3.txt
    grep "kraken:taxid|" ${FOLDER_OUTPUT}${p}.fasta | wc -l >> ${CONSERVED_SEQ_FOLDER}/conserved_sorted_temp3.txt
done < ${CONSERVED_SEQ_FOLDER}/conserved_sorted_temp2.txt

echo "conserved_sorted_temp3.txt is created"

# Join temp1 and temp3 and create counter file.
join -1 2 -2 1 ${CONSERVED_SEQ_FOLDER}/conserved_sorted_temp1.txt ${CONSERVED_SEQ_FOLDER}/conserved_sorted_temp3.txt \
    | sort -k2,2 -gr > ${CONSERVED_SEQ_FOLDER}/countbis.txt

echo "countbis.txt is created"
