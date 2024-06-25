localrules: dl
rule dl:
    params:
        uri=lambda wc: config["datasets"].get(wc.d).get("uri"),
    priority:
        2
    output: 
        "results/fastq/{d}.fastq.gz"
    shell:
        "wget {params.uri} -O {output}"