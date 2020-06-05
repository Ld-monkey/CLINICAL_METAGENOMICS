import os
# Using snakemake file to create a metagenomic pipeline.

reads_path = ["data/reads/PAIRED_SAMPLES_ADN_TEST/",
              "data/reads/PAIRED_SAMPLES_ADN_TEST_2/"]

#print(reads_path)
sample = []
for read in reads_path:
    sample.append(os.path.basename(os.path.dirname(read)))

rule all:
    input:
        expand("results/trimmed_reads/trimmed_{folder}_reads_04_06_2020/", folder=sample)
        
# Remove all poor quality and duplicate reads.
rule rm_poor_quality_and_duplicate:
    input:
        "data/reads/{folder}/"
    output:
        "results/trimmed_reads/trimmed_{folder}_reads_04_06_2020/"
    conda:
        "metagenomic_env.yml"
    shell:
        "bash src/bash/remove_poor_quality_duplicate_reads.sh "
        "-path_reads {input} "
        "-path_output {output}"





