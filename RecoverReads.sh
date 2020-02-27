source activate EnvAntL
export PATH=/data2/home/alarme/miniconda3/bin:$PATH

List=$1
Fastq1=$2
Fastq2=$3
outputFile=$4

TMPDIR=/data2/home/masalm/tempfiles

if [[ -s $List && -s $Fastq1 && -s $Fastq2 ]]
then
    echo "OK for $Fastq1 $Fastq2 $List"

    temp_file=$(mktemp)
    temp_fasta=$(mktemp)
    seqtk subseq $Fastq1 $List >  $temp_file
    seqtk seq -a $temp_file > $temp_fasta

    if [ $? -eq 0 ]; then
        rm $temp_file
        if [[ -s $temp_fasta ]]
        then
            echo "Reads recovered for $Fastq1"
        else
        echo "Reads not recovered for $Fastq1"
        fi
    else
        echo "FAIL for $Fastq1"
    fi

    temp_file1=$(mktemp)
    temp_fasta1=$(mktemp)
    seqtk subseq  $Fastq2 $List >  $temp_file1
    seqtk seq -a $temp_file1 > $temp_fasta1

    if [ $? -eq 0 ]; then
        rm $temp_file1
        if [[ -s $temp_fasta1 ]]
        then
        echo "Reads recovered for $Fastq2"
        else
        echo "Reads not recovered for $Fastq2"
        fi
    else
        echo "FAIL for $Fastq2"
    fi

    if [[ -s $temp_fasta && -s $temp_fasta1 ]]
    then
        cat $temp_fasta $temp_fasta1  >  ${outputFile}
        rm $temp_fasta
        rm $temp_fasta1
    elif [[ ! -s $temp_fasta && -s $temp_fasta1 ]]
    then
       mv $temp_fasta1 ${outputFile}
    elif [[ -s $temp_fasta && ! -s $temp_fasta1 ]]
    then
       mv $temp_fasta ${outputFile}
    elif [[ ! -s $temp_fasta && ! -s $temp_fasta1 ]]
    then
       echo "Non reads recovered at all"
    fi

elif [[ -s $List && -s $Fastq1 ]]
then
    echo "OK for $Fastq1 and $List"

    temp_file=$(mktemp)
    temp_fasta=$(mktemp)
    seqtk subseq $Fastq1 $List >  $temp_file
    seqtk seq -a $temp_file > $temp_fasta

    if [ $? -eq 0 ]; then
        rm $temp_file
        if [[ -s $temp_fasta ]]
        then
            echo "Reads recovered for $Fastq1"
        else
        echo "Reads not recovered for $Fastq1"
        fi
    else
        echo "FAIL for $Fastq1"
    fi

    if [[ -s $temp_fasta ]]
    then
      mv $temp_fasta ${outputFile}
    else
      echo "No reads recovered at all"
    fi
else
    echo "$Fastq1 or/and $Fastq2 or/and $List empty"
fi
