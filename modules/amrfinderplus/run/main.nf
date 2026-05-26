process AMRFINDERPLUS_RUN {
    tag "$meta.id"
    label 'process_micro'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}amrfinderplus${params.fs}4.2.7" : null)
    conda (params.enable_conda ? "bioconda::ncbi-amrfinderplus=4.2.7 conda-forge::bzip2" : null)
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ncbi-amrfinderplus:4.2.7--hf69ffd2_0':
        'quay.io/biocontainers/ncbi-amrfinderplus:4.2.7--hf69ffd2_0' }"

    input:
        tuple val(meta), path(fasta)
        path db

    output:
        tuple val(meta), path("${prefix}.tsv")          , emit: report
        tuple val(meta), path("${prefix}-mutations.tsv"), emit: mutation_report, optional: true
        env 'VER'                                       , emit: tool_version
        env 'DBVER'                                     , emit: db_version
        path "versions.yml"                             , emit: versions


    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args   ?: ''
        prefix   = task.ext.prefix ?: "${meta.id}"
        def is_compressed_fasta = fasta.getName().endsWith(".gz") ? true : false
        def is_compressed_db = db.getName().endsWith(".gz") ? true : false

        organism_param = meta.containsKey("organism") ? "--organism ${meta.organism} --mutation_all ${prefix}-mutations.tsv" : ""
        fasta_name = fasta.getName().replace(".gz", "")
        fasta_param = "-n"
        if (meta.containsKey("is_proteins")) {
            if (meta.is_proteins) {
                fasta_param = "-p"
            }
        }
        """
        if [ "${is_compressed_fasta}" == "true" ]; then
            gzip -c -d ${fasta} > ${fasta_name}
        fi

        if [ "${is_compressed_db}" == "true" ]; then
            mkdir amrfinderdb
            tar xzvf ${db} -C amrfinderdb
        else
            mv ${db} amrfinderdb
        fi

        amrfinder \\
            ${fasta_param} ${fasta_name} \\
            ${organism_param} \\
            ${args} \\
            --database amrfinderdb \\
            --threads ${task.cpus} > ${prefix}.tsv

        VER=\$(amrfinder --version)
        DBVER=\$(amrfinder --database amrfinderdb --database_version 2>&1 | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}\\.[0-9]+' | tail -1)

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            amrfinder: \$VER
            amrfinder_db_version: \$DBVER
        END_VERSIONS
        """
}