rule align_to_txome:
    """
    see params from https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6668388/
    https://github.com/lh3/minimap2/issues/1091
    https://github.com/lh3/minimap2/issues/340
    """
    input:
        fq = rules.dl.output,
        ref = config.get("reference_txome")
    output:
        temp("results/minimap2/{d}.sam")
    threads:
        64
    resources:
        mem_mb = 48000,
        runtime = 360,
        cpus_per_task = 64
    priority:
        3
    singularity:
        "docker://quay.io/biocontainers/minimap2:2.28--he4a0461_1"
    shell:
        "minimap2 -ax map-ont -Y -N 100 -p 0.99 -c -t {threads} {input.ref} {input.fq} > {output}"

rule sort_sam:
    input:
        "results/minimap2/{d}.sam"
    output:
        bam = "results/minimap2/{d}.sorted.bam",
        bai = "results/minimap2/{d}.sorted.bam.bai"
    threads:
        24
    resources:
        mem_mb = 24000,
        runtime = 60,
        cpus_per_task = 24
    priority:
        4
    singularity:
        "docker://quay.io/biocontainers/samtools:1.20--h50ea8bc_0"
    shell:
        "samtools sort -@ {threads} -o {output.bam} {input} && samtools index {output.bam}"