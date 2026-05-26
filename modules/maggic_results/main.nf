process MAGGIC_RESULTS {
    tag "${meta.id}"
    label "process_pico"

    module (params.enable_module ? "${params.swmodulepath}${params.fs}python${params.fs}3.8.1" : null)
    conda (params.enable_conda ? "conda-forge::python=3.9.5" : null)
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.9--1' :
        'quay.io/biocontainers/python:3.9--1' }"

    input:
        tuple val(meta), path(gtdbtk_res), \
                path(genomad_res), \
                path(amrfinderplus_res), \
                path(coverm_res), \
                path(binette_res)

    output:
        tuple val(meta), path("maggic-results.tsv")        , emit: results
        tuple val(meta), path("maggic-globalabundance.tsv"), emit: abundance
        path "versions.yml"                                , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        """
        maggic_results.py \\
            "." \\
            -o maggic-results.tsv

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            python: \$( python --version | sed 's/Python //g' )
        END_VERSIONS
        """
}