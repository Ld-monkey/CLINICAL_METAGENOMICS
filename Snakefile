# Using snakemake file to create a metagenomic pipeline.

reads_path = ["data/reads/PAIRED_SAMPLES_ADN_TEST/"] 

# Remove all poor quality and duplicate reads.
rule rm_poor_quality_and_duplicate:
    input:
        reads=expand("{sample}", sample=reads_path)
    output:
        directory("results/trimmed_reads/trimmed_samples_reads_04_06_2020/")
    conda:
        "metagenomic_env.yml"
    shell:
        "bash src/bash/remove_poor_quality_duplicate_reads.sh -path_reads {input.reads} -path_output {output}"
