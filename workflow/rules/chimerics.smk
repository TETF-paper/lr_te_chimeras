rule find_possible_te_chimeras:
    input:
        bam = rules.sort_sam.output.bam,
        tsv = config.get("gene_lookup")
    output:
        tsv = "results/chimeric/{d}/possible_te_chimeras.tsv"
    conda:
        "../envs/r.yaml"
    threads:
        1
    resources:
        mem_mb = 24000,
        runtime = 120,
        cpus = 1
    script:
        "../scripts/find_possible_te_chimeras.R"

localrules: combine_possible_te_chimeras
rule combine_possible_te_chimeras:
    """
    keep only the chimeras that are found in more than one dataset
    """
    input:
        expand("results/chimeric/{d}/possible_te_chimeras.tsv", d = config.get("datasets"))
    output:
        tsv = "results/chimeric/possible_te_chimeras.tsv.gz"
    shell:
        """
        head -n 1 {input[0]} | gzip -c > {output}
        tail -n +2 {input} | grep -v "==>" | sort | uniq -c | \
            tr -s ' ' '\t' | sed 's/^[ \t]*//' | \
            awk '$1 > 1' | awk '$2 != "NA"' | \
            cut -f 2- |
            gzip -c >> {output}
        """
