# Using snakemake file to create a metagenomic pipeline.
import os

reads_path = ["data/reads/PAIRED_SAMPLES_ADN_TEST/"]

all_database = ["fda_argos_with_none_library_kraken_database_07_06_2020",
                "mycocosm_with_fungi_library_kraken_database_07_06_2020"]

all_raw_sequences = ["fda_argos_raw_genomes_assembly_06_06_2020",
                     "mycocosm_fungi_ncbi_CDS_07_06_2020"]

sample = []
for read in reads_path:
    sample.append(os.path.basename(os.path.dirname(read)))

rule all:
    input:
        expand("results/trimmed_reads/trimmed_{folder}_reads_04_06_2020/",
               folder=sample),
        # "data/raw_sequences/fda_argos_raw_genomes_assembly_06_06_2020/",
        # "data/databases/fda_argos_with_none_library_kraken_database_07_06_2020/",
        #expand("results/classify_reads/trimmed_classify_{folder}_with_fda_argos_none_library_database/",
        #       folder=sample),
        #expand("data/reads/{folder}/",
        #       folder=sample),
        #"data/databases/mycocosm_with_fungi_library_kraken_database_07_06_2020/",
        #"results/blast_results/blast_PAIRED_SAMPLES_ADN_TEST/"
        #expand("results/blast_results/blast_result_{folder_blast}/", folder_blast=all_database)
        #"results/final_results/"
        #expand("results/final_results/{folder_a}/", folder_a=all_database)
        #expand("results/html_final/{folder_a}/",
        #       folder_a=all_database)

# Remove all poor quality and duplicate reads.
rule remove_poor_quality_and_duplicate_reads:
    input: 
        "data/reads/PAIRED_SAMPLES_ADN_TEST/"
    output:
        directory("results/trimmed_reads/trimmed_PAIRED_SAMPLES_ADN_TEST_reads_01_07_2020/")
    conda:
        "metagenomic_env.yml"
    threads : 27
    shell:
        "bash src/bash/remove_poor_quality_duplicate_reads_preprocess.sh "
        "-path_reads {input} "
        "-path_output {output} "
        "-threads {threads} "
        "-force_remove no"


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


# Create FDA ARGOS metagenomic kraken 2 database without other library.
rule create_fda_argos_kraken_2_database:
    input:
        raw="data/raw_sequences/fda_argos_raw_genomes_assembly_06_06_2020/",
        taxonomy="data/taxonomy/ncbi_taxonomy_29_06_2020/"
    output:
        directory("data/databases/kraken_2/fda_argos_with_none_library_kraken_database_07_06_2020/")
    params:
        type_database = "none"
    threads : 27
    conda:
        "metagenomic_env.yml"
    shell:
        "bash src/bash/create_kraken_database.sh "
        "-path_seq {input.raw} "
        "-path_db {output} "
        "-type_db {params.type_database} "
        "-taxonomy {input.taxonomy} "
        "-threads {threads}"

# Create refseq (viral+bacteria) kraken 2 database.
rule create_refseq_viral_bacteria_kraken_2_database:
    input:
        taxonomy="data/taxonomy/ncbi_taxonomy_29_06_2020/"
    output:
        directory("data/databases/kraken_2/refseq_with_viral_bacteria_libraries_kraken_database_30_06_2020/")
    params:
        type_database = "\"bacteria viral\""
    threads : 27
    conda:
        "metagenomic_env.yml"
    shell:
        "bash src/bash/create_kraken_database.sh "
        "-path_db {output} "
        "-type_db {params.type_database} "
        "-taxonomy {input.taxonomy} "
        "-threads {threads}"


# Download all genomes mycocosm aka fungi.
# Be careful about username and password files that contain privates informations.
# You must create you own jgi account and put informations in respective files.
rule download_all_genomes_mycocosm_fungi_database:
    input:
        username="src/download/username",
        password="src/download/password"
    output:
        "src/download/all_organisms.csv",
        raw_sequence=directory("data/raw_sequences/mycocosm_fungi_ncbi_CDS_07_06_2020/")
    conda:
        "metagenomic_env.yml"
    shell:
        "username=$(cat {input.username} );"
        "password=$(cat {input.password} );"
        "python src/download/download_jgi_genomes.py "
        "-u $username "
        "-p $password "
        "-out {output.raw_sequence}"


# Add the correct ncbi id taxonomy for all genomes following manual instruction
# of kraken 2 to create a custom database.
rule add_correct_kraken_id_mycocosm:
    input:
        "data/raw_sequences/mycocosm_fungi_ncbi_CDS_07_06_2020/"
    output:
        mycocosm_cds=directory("data/raw_sequences/mycocosm_fungi_ncbi_CDS_07_06_2020/")
    params:
        csv="src/download/all_organisms.csv"
    conda:
        "metagenomic_env.yml"
    shell:
        "python src/python/jgi_id_to_ncbi_id_taxonomy.py "
        "-csv {params.csv} "
        "-path_sequence {output.mycocosm_cds}"

# Create mycocosm metagenomic kraken 2 database.
rule create_mycocosm_database:
    input:
        "data/raw_sequences/mycocosm_fungi_ncbi_CDS_07_06_2020/"
    output:
        directory("data/databases/mycocosm_with_fungi_library_kraken_database_07_06_2020/")
    params:
        type_database = "fungi",
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
        database=expand("data/databases/{database}/", database=all_database)
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

# Create a blast database
rule create_blast_database_without_low_complexity:
    input:
        raw_sequences=expand("data/raw_sequences/{folder_raw}/", folder_raw=all_raw_sequences)
    output:
        output_folder=expand("data/raw_sequences/{folder_output}/", folder_output=all_raw_sequences)
    params:
        name_database=expand("{folder}_blast_database", folder=sample)
    conda:
        "metagenomic_env.yml"
    shell:
        "bash src/bash/create_blast_database_without_low_complexity.sh"
        "-path_seqs {input.raw_sequences} "
        "-output_fasta {output.output_folder}/makeblast/ "
        "-name_db {params.name_database}"


# run blast analyse.
rule run_mega_blast:
    input:
        read=expand("results/classify_reads/trimmed_classify_{folder}_with_fda_argos_none_library_database/", folder=sample),
        raw_sequences=expand("data/raw_sequences/{folder_output}/", folder_output=all_raw_sequences)
    output:
        blast_result=expand("results/blast_results/blast_result_{folder_blast}/", folder_blast=all_database) 
    conda:
        "metagenomic_env.yml"
    shell:
        "bash src/bash/launch_blast_analyse.sh "
        "-path_reads {input.read} "
        "-path_db {input.blast_database}/makeblast/ "
        "-path_results {output.blast_result}"


# run recovers same id from kraken and blast classification.
rule recovers_same_id_from_kraken_and_blast:
    input:
        reads_output=expand("results/classify_reads/trimmed_classify_{folder}_with_fda_argos_none_library_database/", folder=sample),
        blast_result=expand("results/blast_results/blast_result_{folder_blast}/", folder_blast=all_database)
    output:
        expand("results/final_results/{folder_a}/", folder_a=all_database)
    params:
        ncbi="data/databases/ete3_ncbi_taxanomy_database_05_05_2020/"
    conda:
        "metagenomic_env.yml"
    shell:
        "bash find_same_id_kraken_blast_bacteria_test.sh "
        "-path_taxo {input.reads_output} "
        "-path_blast {input.blast_result} "
        "-path_clseq {input.reads_output} "
        "-path_ncbi {params.ncbi}"

# create plot for analyse.
rule create_plot_analyse:
    input:
        folder_plot=expand("results/final_results/{folder_a}/",
                           folder_a=all_database)
    output:
        folder_html=expand("results/html_final/{folder_a}/",
                           folder_a=all_database)
    conda:
        "metagenomic_env.yml"
    shell:
        "python src/python/create_depth_plot.py "
        "{input.folder_plot}"
