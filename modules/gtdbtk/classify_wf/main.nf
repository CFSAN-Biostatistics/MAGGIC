process GTDBTK_CLASSIFY_WF {
    tag "${meta.id}"
    label 'process_high_turbo'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}gtdbtk${params.fs}2.5.2" : null)
    conda (params.enable_conda ? "bioconda::gtdbtk=2.7.1 conda-forge::bz2" : null)
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gtdbtk:2.7.2--pyhdfd78af_0' :
        'quay.io/biocontainers/gtdbtk:2.7.2--pyhdfd78af_0' }"

    input:
        tuple val(meta), path(genomes, stageAs: 'final_bins/*')

    output:
        tuple val(meta), path("${prefix}_gtdbtk_classify_wf"), emit: results
        path "versions.yml"                                  , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        // def safe_tmp = "tmp." + "${task.process.replaceAll(/\W+/, '-')}" + '-' + "${task.index}"
        def safe_tmp = "/tmp"
        prefix = task.ext.prefix ?: "${meta.id}"
        """
        # mkdir -p "${safe_tmp}" || exit 1

        gtdbtk classify_wf \\
            ${args} \\
            --genome_dir final_bins \\
            --out_dir ${prefix}_gtdbtk_classify_wf \\
            --cpus ${task.cpus} \\
            --pplacer_cpus ${task.cpus} \\
            --tmpdir "${safe_tmp}"

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            gtdbtk: \$( gtdbtk --version 2>&1 | grep -Eo '[0-9]+(\\.[0-9]+)+' | head -1 )
        END_VERSIONS
        """
}