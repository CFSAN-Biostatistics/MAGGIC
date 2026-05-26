process SEMIBIN2_SEB {
    tag "${meta.id}"
    label 'process_low'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}semibin${params.fs}2.2.1" : null)
    conda (params.enable_conda ? "bioconda::semibin=2.2.1 conda-forge::bzip2" : null)
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/semibin:2.2.1--pyhdfd78af_0':
        'quay.io/biocontainers/semibin:2.2.1--pyhdfd78af_0' }"

    input:
        tuple val(meta), path(fasta), path(bam)

    output:
        tuple val(meta), path("${prefix}/*.csv")                   , emit: csv, optional: true
        tuple val(meta), path("${prefix}/*.h5")                    , emit: model, optional: true
        tuple val(meta), path("${prefix}/*.tsv")                   , emit: tsv, optional: true
        tuple val(meta), path("${prefix}/output_bins/*.{fa,fa.gz}"), emit: bins, optional: true
        path "versions.yml"                                        , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args  = task.ext.args ?: ''
        def args2 = task.ext.args2 ?: ""
        def bams = "${bam.join(' --input-bam ')}"
        prefix    = task.ext.prefix ?: "${meta.id}"
        """
        SemiBin2 \\
            single_easy_bin \\
            ${args} \\
            ${args2} \\
            --tmpdir "." \\
            --input-fasta ${fasta} \\
            --input-bam ${bams} \\
            --output ${prefix} \\
            -t ${task.cpus} \\

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            semibin2: \$( SemiBin2 --version )
        END_VERSIONS
        """
}