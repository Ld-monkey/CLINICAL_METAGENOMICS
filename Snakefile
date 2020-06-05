import os
# Using snakemake file to create a metagenomic pipeline.

reads_path = ["data/reads/PAIRED_SAMPLES_ADN_TEST/"]

database = ["database_fda_refseq_human_viral"]

#print(reads_path)
sample = []
for read in reads_path:
    sample.append(os.path.basename(os.path.dirname(read)))

rule all:
    input:
        expand("results/trimmed_reads/trimmed_{folder}_reads_04_06_2020/",
               folder=sample),
        expand("results/reads_outputs/trimmed_classify_{folder}_with_database_fda_refseq_human_viral/",
               folder=sample)
        
# Remove all poor quality and duplicate reads.
rule remove_poor_quality_and_duplicate_reads:
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

# Classify reads on databases.
rule classify_reads_with_database:
    input:
        read="results/trimmed_reads/trimmed_{folder}_reads_04_06_2020/",
        database=expand("data/databases/{db}/", db = database)
    output:
        reads_output=directory("results/reads_outputs/trimmed_classify_{folder}_with_database_fda_refseq_human_viral/")
    params:
        threads = 7
    conda:
        "metagenomic_env.yml"
    shell:
        "bash src/bash/classify_set_sequences.sh "
        "-path_reads {input.read} "
        "-path_db {input.database} "
        "-path_output {output.reads_output} "
        "-threads {params.threads} "
