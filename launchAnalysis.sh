#!/bin/bash
#$ -S /bin/bash
#$ -N MetaStudStep1
#$ -cwd
#$ -o outMeta.out
#$ -e errMeta.err
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

#qsub launchAnalysis.sh {folder}

source activate EnvAntL

folderInput=$1
export folderInput

folderInputB=$1/Bacteria
folderInputV=$1/Viruses

blast=$(ls $folderInputV | grep -i blast)
export folderInputV

parallel '
  clseqs1=$(echo {} | sed "s/blast.txt/clseqs_1.fastq/")
  clseqs2=$(echo {} | sed "s/blast.txt/clseqs_2.fastq/")
  conserved=$(echo {} | sed "s/blast.txt/conserved.txt/")
  counting=$(echo {} | sed "s/blast.txt/countbis.txt/")
  basename_fasta=$(echo {} | sed "s/.blast.txt/fasta/")
  temp1=$(echo {} | sed "s/blast.txt/temp1.txt/")
  temp2=$(echo {} | sed "s/blast.txt/temp2.txt/")
  temp3=$(echo {} | sed "s/blast.txt/temp3.txt/")
  mkdir -p ${folderInputV}/${basename_fasta}
  rm ${folderInputV}/${basename_fasta}/*
  ./SortBlastedSeq.py ${folderInputV} {}
  cat ${folderInputV}/${conserved} |awk -v pathF="${folderInputV}/${basename_fasta}" -F"[\t]" '\''$10~/^1/ {print $1" "$8 > pathF"/map1.fa" ; print $1 > pathF"/1.fa" }'\''
  cat ${folderInputV}/${conserved} |awk -v pathF="${folderInputV}/${basename_fasta}" -F"[\t]" '\''$10~/^2/ {print $1" "$8 > pathF"/map2.fa" ; print $1 > pathF"/2.fa"}'\''
  ./RecoverReads.sh ${folderInputV}/${basename_fasta}/1.fa ${folderInput}/${clseqs1} empty.txt ${folderInputV}/${basename_fasta}/1.fasta
  ./RecoverReads.sh ${folderInputV}/${basename_fasta}/2.fa ${folderInput}/${clseqs2} empty.txt ${folderInputV}/${basename_fasta}/2.fasta
  cat ${folderInputV}/${basename_fasta}/1.fasta | paste - - | cut -c2- |sort > ${folderInputV}/${basename_fasta}/sorted1.fasta
  cat ${folderInputV}/${basename_fasta}/2.fasta | paste - - | cut -c2- |sort > ${folderInputV}/${basename_fasta}/sorted2.fasta
  sort ${folderInputV}/${basename_fasta}/map1.fa > ${folderInputV}/${basename_fasta}/sorted1.fa
  sort ${folderInputV}/${basename_fasta}/map2.fa > ${folderInputV}/${basename_fasta}/sorted2.fa
  join -11 -21 ${folderInputV}/${basename_fasta}/sorted1.fasta ${folderInputV}/${basename_fasta}/sorted1.fa > ${folderInputV}/${basename_fasta}/1.fasta
  join -11 -21 ${folderInputV}/${basename_fasta}/sorted2.fasta ${folderInputV}/${basename_fasta}/sorted2.fa > ${folderInputV}/${basename_fasta}/2.fasta
  cat ${folderInputV}/${basename_fasta}/1.fasta |awk -v pathF="${folderInputV}/${basename_fasta}" '\''{print ">"$1" "$2" "$3"\n"$4 > pathF"/"$5".fasta"}'\''
  cat ${folderInputV}/${basename_fasta}/2.fasta |awk -v pathF="${folderInputV}/${basename_fasta}" '\''{print ">"$1" "$2" "$3"\n"$4 >> pathF"/"$5".fasta"}'\''
  rm ${folderInputV}/${basename_fasta}/1.fasta ${folderInputV}/${basename_fasta}/2.fasta ${folderInputV}/${basename_fasta}/1.fa ${folderInputV}/${basename_fasta}/2.fa
  rm ${folderInputV}/${basename_fasta}/map1.fa ${folderInputV}/${basename_fasta}/map2.fa ${folderInputV}/${basename_fasta}/sorted1.fa ${folderInputV}/${basename_fasta}/sorted2.fa
  rm ${folderInputV}/${basename_fasta}/sorted1.fasta ${folderInputV}/${basename_fasta}/sorted2.fasta
  find ${folderInputV}/${basename_fasta} -type f |
  while read f; do
  	i=0
  	while read line; do
  		i=$((i+1))
  		[ $i -eq 10 ] && continue 2
  	done < "$f"
  	printf %s\\n "$f"
  done |
  xargs rm -f
  sort -n ${folderInputV}/${conserved} -k8,8 > ${folderInputV}/{}sorted.txt
  rm ${folderInputV}/${conserved}
  mv ${folderInputV}/{}sorted.txt ${folderInputV}/${conserved}
  cut -f8 ${folderInputV}/${conserved} | uniq -c > ${folderInputV}/${temp1}
  cut -f8 ${folderInputV}/${conserved} | uniq > ${folderInputV}/${temp2}
  while read p;
  do
    echo -n $p" " >> ${folderInputV}/${temp3}
    grep "kraken:taxid|"$p ${folderInputV}/{} | wc -l >> ${folderInputV}/${temp3}
  done<${folderInputV}/${temp2}
  join -1 2 -2 1 ${folderInputV}/${temp1} ${folderInputV}/${temp3} |sort -k2,2 -gr > ${folderInputV}/${counting}
  ./CreateDepthPlot.py ${folderInputV} ${conserved} ${counting}
  rm ${folderInputV}/${counting}
  rm ${folderInputV}/${temp1} ${folderInputV}/${temp2} ${folderInputV}/${temp3}
  '  ::: ${blast}



blast=$(ls $folderInputB | grep -i blast)
export folderInputB

parallel '
  clseqs1=$(echo {} | sed "s/blast.txt/clseqs_1.fastq/")
  clseqs2=$(echo {} | sed "s/blast.txt/clseqs_2.fastq/")
  conserved=$(echo {} | sed "s/blast.txt/conserved.txt/")
  counting=$(echo {} | sed "s/blast.txt/countbis.txt/")
  temp1=$(echo {} | sed "s/blast.txt/temp1.txt/")
  temp2=$(echo {} | sed "s/blast.txt/temp2.txt/")
  temp3=$(echo {} | sed "s/blast.txt/temp3.txt/")
  basename_fasta=$(echo {} | sed "s/.blast.txt/fasta/")
  mkdir -p ${folderInputB}/${basename_fasta}
  ./SortBlastedSeq.py ${folderInputB} {}
  cat ${folderInputB}/${conserved} |awk -v pathF="${folderInputB}/${basename_fasta}" -F"[\t]" '\''$10~/^1/ {print $1" "$8 > pathF"/map1.fa" ; print $1 > pathF"/1.fa" }'\''
  cat ${folderInputB}/${conserved} |awk -v pathF="${folderInputB}/${basename_fasta}" -F"[\t]" '\''$10~/^2/ {print $1" "$8 > pathF"/map2.fa" ; print $1 > pathF"/2.fa"}'\''
  ./RecoverReads.sh ${folderInputB}/${basename_fasta}/1.fa ${folderInput}/${clseqs1} empty.txt ${folderInputB}/${basename_fasta}/1.fasta
  ./RecoverReads.sh ${folderInputB}/${basename_fasta}/2.fa ${folderInput}/${clseqs2} empty.txt ${folderInputB}/${basename_fasta}/2.fasta
  cat ${folderInputB}/${basename_fasta}/1.fasta | paste - - | cut -c2- |sort > ${folderInputB}/${basename_fasta}/sorted1.fasta
  cat ${folderInputB}/${basename_fasta}/2.fasta | paste - - | cut -c2- |sort > ${folderInputB}/${basename_fasta}/sorted2.fasta
  sort ${folderInputB}/${basename_fasta}/map1.fa > ${folderInputB}/${basename_fasta}/sorted1.fa
  sort ${folderInputB}/${basename_fasta}/map2.fa > ${folderInputB}/${basename_fasta}/sorted2.fa
  join -11 -21 ${folderInputB}/${basename_fasta}/sorted1.fasta ${folderInputB}/${basename_fasta}/sorted1.fa > ${folderInputB}/${basename_fasta}/1.fasta
  join -11 -21 ${folderInputB}/${basename_fasta}/sorted2.fasta ${folderInputB}/${basename_fasta}/sorted2.fa > ${folderInputB}/${basename_fasta}/2.fasta
  cat ${folderInputB}/${basename_fasta}/1.fasta |awk -v pathF="${folderInputB}/${basename_fasta}" '\''{print ">"$1" "$2" "$3"\n"$4 > pathF"/"$5".fasta"}'\''
  cat ${folderInputB}/${basename_fasta}/2.fasta |awk -v pathF="${folderInputB}/${basename_fasta}" '\''{print ">"$1" "$2" "$3"\n"$4 >> pathF"/"$5".fasta"}'\''
  rm ${folderInputB}/${basename_fasta}/1.fasta ${folderInputB}/${basename_fasta}/2.fasta ${folderInputB}/${basename_fasta}/1.fa ${folderInputB}/${basename_fasta}/2.fa
  rm ${folderInputB}/${basename_fasta}/map1.fa ${folderInputB}/${basename_fasta}/map2.fa ${folderInputB}/${basename_fasta}/sorted1.fa ${folderInputB}/${basename_fasta}/sorted2.fa
  rm ${folderInputB}/${basename_fasta}/sorted1.fasta ${folderInputB}/${basename_fasta}/sorted2.fasta
  find ${folderInputB}/${basename_fasta} -type f |
  while read f; do
    i=0
    while read line; do
      i=$((i+1))
      [ $i -eq 10 ] && continue 2
    done < "$f"
    printf %s\\n "$f"
  done |
  xargs rm -f
  sort -n ${folderInputB}/${conserved} -k8,8 > ${folderInputB}/{}sorted.txt
  rm ${folderInputB}/${conserved}
  mv ${folderInputB}/{}sorted.txt ${folderInputB}/${conserved}
  cut -f8 ${folderInputB}/${conserved} | uniq -c |sort -k2,2 -g > ${folderInputB}/${temp1}
  cut -f2,8 ${folderInputB}/${conserved} | sort -k1 | uniq | cut -f2 | sort -g | uniq -c > ${folderInputB}/${temp2}
  join -1 2 -2 2 ${folderInputB}/${temp1} ${folderInputB}/${temp2} |sort -k1,1b > ${folderInputB}/${temp3}
  join -1 1 -2 1 ${folderInputB}/${temp3} /data2/home/masalm/Antoine/DB/MetaPhlAn/totalCountofGenes.txt | sort -k2,2 -gr > ${folderInputB}/${counting}
  ./getNames.py ${folderInputB}/${counting}
  rm ${folderInputB}/${counting}
  rm ${folderInputB}/${temp1} ${folderInputB}/${temp2} ${folderInputB}/${temp3}
  '  ::: ${blast}

source deactivate
