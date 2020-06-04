# Using snakemake file to create a metagenomic pipeline.

# All path of sample reads.
SAMPLES_READS = ["1-MAR-LBA-ADN_S1_R1_paired",
                 "1-MAR-LBA-ADN_S1_R2_paired"]

# Remove all poor quality and duplicate reads.
rule rm_poor_quality_and_duplicate:
    input:
        path_reads="data/reads/PAIRED_SAMPLES_ADN/"
    output:
        "results/"
    conda:
        "metagenomic_env.yml"
    shell:
        "src/bash/remove_poor_quality_duplicate_reads.sh -path_reads {path_reads}"


# Classify a set of sequences.
rule classify_reads:
    input:
        path_reads="data/reads/PAIRED_SAMPLES_ADN/"
    output:
        ""
    conda:
        "metagenomic_env.yml"
    shell:
        "src/bash"
