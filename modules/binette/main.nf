process BINETTE {
    tag "${meta.id}"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::binette=1.2.1 conda-forge::click" : null)
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/binette:1.2.1--pyh7e72e81_0':
        'quay.io/biocontainers/binette:1.2.1--pyh7e72e81_0' }"

    input:
        tuple val(meta), path(fasta), path(bin_dirs, stageAs: 'bins/*')

    output:
        tuple val(meta), path("${prefix}_binette/final_bins_quality_reports.tsv"), emit: quality_report, optional: true
        tuple val(meta), path("${prefix}_binette/final_bins/*.fa")               , emit: bins, optional: true
        path "versions.yml"                                                      , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        prefix = task.ext.prefix ?: "${meta.id}"
        """
        binette \\
            ${args} \\
            -t ${task.cpus} \\
            --bin_dirs bins \\
            -c ${fasta} \\
            --prefix ${prefix} \\
            -o ${prefix}_binette \\

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            binette: \$( binette --version 2>&1 | sed 's/Binette //')
        END_VERSIONS
        """
}