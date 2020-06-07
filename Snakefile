# Using snakemake file to create a metagenomic pipeline.
import os

reads_path = ["data/reads/PAIRED_SAMPLES_ADN_TEST/"]

sample = []
for read in reads_path:
    sample.append(os.path.basename(os.path.dirname(read)))

rule all:
    input:
        expand("results/trimmed_reads/trimmed_{folder}_reads_04_06_2020/",
               folder=sample),
        "data/raw_sequences/fda_argos_raw_genomes_assembly_06_06_2020/",
        "data/databases/fda_argos_with_none_library_kraken_database_07_06_2020/",
        expand("results/classify_reads/trimmed_classify_{folder}_with_fda_argos_none_library_database/",
               folder=sample)

        
# Remove all poor quality and duplicate reads.
rule remove_poor_quality_and_duplicate_reads:
    input:
        "data/reads/{folder}/"
    output:
        directory("results/trimmed_reads/trimmed_{folder}_reads_04_06_2020/")
    conda:
        "metagenomic_env.yml"
    shell:
        "bash src/bash/remove_poor_quality_duplicate_reads.sh "
        "-path_reads {input} "
        "-path_output {output}"


# Download all assembly FDA ARGOS database.
rule download_fda_argos_database:
    input:
        xml="data/assembly/assembly_fda_argos_ncbi_result.xml"
    output:
        directory("data/raw_sequences/fda_argos_raw_genomes_assembly_06_06_2020/")
    conda:
        "metagenomic_env.yml"
    shell:
        "bash src/download/download_fda_argos_assembly.sh "
        "-assembly_xml {input.xml} "
        "-path_output {output}"


# Create FDA ARGOS metagenomic kraken 2 database.
rule create_fda_argos_database:
    input:
        "data/raw_sequences/fda_argos_raw_genomes_assembly_06_06_2020/"
    output:
        directory("data/databases/fda_argos_with_none_library_kraken_database_07_06_2020/")
    params:
        type_database = "none",
        threads = 7
    conda:
        "metagenomic_env.yml"
    shell:
        "bash src/bash/create_kraken_database.sh "
        "-path_seq {input} "
        "-path_db {output} "
        "-type_db {params.type_database} "
        "-threads {params.threads}"


# Classify reads with database.
rule classify_reads_with_database:
    input:
        read="results/trimmed_reads/trimmed_{folder}_reads_04_06_2020/",
        database="data/databases/fda_argos_with_none_library_kraken_database_07_06_2020/"
    output:
        reads_output=directory("results/classify_reads/trimmed_classify_{folder}_with_fda_argos_none_library_database/")
    params:
        threads = 7
    conda:
        "metagenomic_env.yml"
    shell:
        "bash src/bash/classify_set_sequences.sh "
        "-path_reads {input.read} "
        "-path_db {input.database} "
        "-path_output {output.reads_output} "
        "-threads {params.threads}"
