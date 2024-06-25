rule find_possible_te_chimeras:
    input:
        bam = rules.sort_sam.output.bam,
        tsv = config.get("gene_lookup")
    output:
        tsv = "results/chimeric/{d}/possible_te_chimeras.tsv"
    script:
        "../scripts/find_possible_te_chimeras.R"

rule all_possible_te_chimeras:
    input:
        expand("results/chimeric/{d}/possible_te_chimeras.tsv", d = config.get("datasets"))
