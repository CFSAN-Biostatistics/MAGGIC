process SAMPLE_COVERAGE {
    tag "${inputdir.simpleName}"
    label "process_pico"

    conda (params.enable_conda ? "conda-forge::python=3.9.5" : null)
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.9--1' :
        'quay.io/biocontainers/python:3.9--1'}"

    input:
        path inputdir

    output:
        path '*.txt'       , emit: table
        path 'versions.yml', emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def suffix_arg = ""
        if (params.coverm_contig_cov_suffix) {
            suffix_arg = "-s '${params.coverm_contig_cov_suffix}'"
        }
        """
        merge_cov_tables.py -i '.' -o merged_cov_table.txt ${suffix_arg}

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            python: \$( python --version | sed 's/Python //g' )
        END_VERSIONS
        """
}