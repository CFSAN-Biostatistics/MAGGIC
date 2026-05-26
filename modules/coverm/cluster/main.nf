process COVERM_CLUSTER {
    tag "${meta.id}"
    label "process_low"

    module (params.enable_module ? "${params.swmodulepath}${params.fs}coverm${params.fs}0.7.0" : null)
    conda (params.enable_conda ? "bioconda::coverm=0.7.0 conda-forge::bzip2" : null)
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/coverm:0.7.0--hcb7b614_4' :
        'biocontainers/coverm:0.7.0--hcb7b614_4' }"

    input:
        tuple val(meta), path(genomes)
        path(quality_report)

    output:
        path("*.tsv"), emit: coverage
        tuple val(meta), path("*_representatives"), emit: representatives
        path("*.list"), emit: representative_list

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ""
        def prefix = task.ext.prefix ?: "${meta.id}"

        """
        TMPDIR=.

        coverm cluster \\
            --genome-fasta-files ${genomes} \\
            --checkm2-quality-report ${quality_report} \\
            --output-representative-fasta-directory ${prefix}_representatives \\
            --output-representative-list ${prefix}_representatives.list \\
            --output-cluster-definition ${prefix}_cluster.tsv \\
            ${args}

        cat <<-END_VERSIONS > versions.yml
            "${task.process}":
                coverm: \$( coverm --version | sed 's/coverm //' )
            END_VERSIONS
        """
}