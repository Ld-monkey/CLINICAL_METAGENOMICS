#!/bin/bash
#$ -S /bin/bash
#$ -N GetIntFasta
#$ -cwd
#$ -o outGetIntFasta.out
#$ -e errGetIntFasta.err
#$ -q short.q
#$ -l h_rt=47:20:00
#$ -pe thread 1
#$ -l h_vmem=20G
#$ -M your@email.com

echo "JOB NAME: $JOB_NAME"
echo "JOB ID: $JOB_ID"
echo "QUEUE: $QUEUE"
echo "HOSTNAME: $HOSTNAME"
echo "SGE O WORKDIR: $SGE_O_WORKDIR"
echo "SGE TASK ID: $SGE_TASK_ID"
echo "NSLOTS: $NSLOTS"

#qsub launchV3GetIntFasta.sh {folder} {Bacteria/Viruses}

source activate EnvAntL
folderInput=$1
kingdomSearched=$2
report=$(ls $folderInput | grep -i .report.txt)
export folderInput
export kingdomSearched

# parallel '
#   mkdir -p ${folderInput}/${kingdomSearched}
#   clseqs1=$(echo {} | sed "s/report.txt/clseqs_1.fastq/")
#   clseqs2=$(echo {} | sed "s/report.txt/clseqs_2.fastq/")
#   outputFile=$(echo {} | sed "s/report.txt/interesting.fasta/")
#   ./GetIntFasta3.py ${folderInput} {} ${kingdomSearched}
#   ./RecoverReads.sh ${folderInput}/${kingdomSearched}/{}ReadsList.txt ${folderInput}/${clseqs1} ${folderInput}/${clseqs2} ${folderInput}/${kingdomSearched}/${outputFile}
#   rm ${folderInput}/${kingdomSearched}/{}ReadsList.txt
#   '  ::: ${report}

for file in ${report}
do
  mkdir -p ${folderInput}/${kingdomSearched}
  clseqs1=$(echo $file | sed "s/report.txt/clseqs_1.fastq/")
  clseqs2=$(echo $file | sed "s/report.txt/clseqs_2.fastq/")
  outputFile=$(echo $file | sed "s/report.txt/interesting.fasta/")
  ./GetIntFasta3.py ${folderInput} $file ${kingdomSearched}
  ./RecoverReads.sh ${folderInput}/${kingdomSearched}/${file}ReadsList.txt ${folderInput}/${clseqs1} ${folderInput}/${clseqs2} ${folderInput}/${kingdomSearched}/${outputFile}
  rm ${folderInput}/${kingdomSearched}/${file}ReadsList.txt
done
source deactivate
