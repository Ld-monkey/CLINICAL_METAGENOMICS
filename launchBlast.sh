#!/bin/bash
#$ -N BlastOnlyVir
#$ -cwd
#$ -o outBlast.out
#$ -e errBlast.err
#$ -q short.q
#$ -l h_rt=47:20:00
#$ -pe thread 40
#$ -l h_vmem=2.75G
#$ -M your@email.com

echo "JOB NAME: $JOB_NAME"
echo "JOB ID: $JOB_ID"
echo "QUEUE: $QUEUE"
echo "HOSTNAME: $HOSTNAME"
echo "SGE O WORKDIR: $SGE_O_WORKDIR"
echo "SGE TASK ID: $SGE_TASK_ID"
echo "NSLOTS: $NSLOTS"

#qsub launchBlast.sh {folder}

source activate EnvAntL
module load blastplus/2.2.31

folderInput=$1
cd ${folderInput}/Viruses
interesting=$(ls | grep -i interesting)

for interestingFile in ${interesting};
do
  cat $interestingFile | parallel --block 1M --recstart '>' --pipe blastn -task megablast -evalue 10e-10 -db /data2/home/masalm/Antoine/DB/RefSeq_viral/refseq_viral_genomic  -num_threads 1 -outfmt \"7 qseqid sseqid sstart send evalue bitscore slen staxids\" -max_target_seqs 1 -max_hsps 1 > ${interestingFile%%.*}.blasttemp.txt
  sed "/\processed\b/d" ${interestingFile%%.*}.blasttemp.txt > ${interestingFile%%.*}.blasttemp2.txt
  tac ${interestingFile%%.*}.blasttemp2.txt | sed '/0 hits/I,+3 d' |tac > ${interestingFile%%.*}.blast.txt
  if [ -s "${interestingFile%%.*}.blast.txt" ]
  then
    rm ${interestingFile%%.*}.blasttemp.txt ${interestingFile%%.*}.blasttemp2.txt
  else
    echo "${interestingFile%%.*}.blast.txt not generated. Available storage space could be the reason !"
  fi
done

cd ../Bacteria
interesting=$(ls | grep -i interesting)
for interestingFile in ${interesting};
do
  cat $interestingFile | parallel --block 50M --recstart '>' --pipe blastn -task megablast -evalue 10e-10 -db /data2/home/masalm/Antoine/DB/MetaPhlAn/mpa_v20_m200_bis.fna -num_threads 1 -outfmt \"7 qseqid sseqid sstart send evalue bitscore slen staxids\" -max_target_seqs 1 -max_hsps 1 > ${interestingFile%%.*}.blasttemp.txt
  #cat $interestingFile | parallel --block 50M --recstart '>' --pipe blastn -task megablast -evalue 10e-10 -db /data2/home/masalm/Antoine/DB/BiBi/procaryota_16S-rDNA-16S_TS-stringent.fasta -num_threads 8 -outfmt \"7 qseqid sseqid sstart send evalue bitscore slen staxids\" -max_target_seqs 1 -max_hsps 1 > ${interestingFile%%.*}.blasttemp.txt
  #blastn -task megablast -query $interestingFile -db /data2/home/masalm/Antoine/DB/BiBi/procaryota_16S-rDNA-16S_TS-stringent.fasta -num_threads 10 -outfmt "7 qseqid sseqid sstart send evalue bitscore slen staxids" -max_target_seqs 1 -max_hsps 1 > ${interestingFile%%.*}.blasttemp.txt
  sed "/\processed\b/d" ${interestingFile%%.*}.blasttemp.txt > ${interestingFile%%.*}.blasttemp2.txt
  tac ${interestingFile%%.*}.blasttemp2.txt | sed '/0 hits/I,+3 d' |tac > ${interestingFile%%.*}.blast.txt
  if [ -s "${interestingFile%%.*}.blast.txt" ]
  then
    rm ${interestingFile%%.*}.blasttemp.txt ${interestingFile%%.*}.blasttemp2.txt
  else
    echo "${interestingFile%%.*}.blast.txt not generated. Available storage space could be the reason !"
  fi
done

# blastn -task megablast -query test -evalue 10e-10 -db /data1/scratch/masalm/db/fungi.genomic.fasta -num_threads 1 -outfmt "7 qseqid sseqid sstart send evalue bitscore slen staxids" -max_target_seqs 1 -max_hsps 1 > blast.result.txt
source deactivate
