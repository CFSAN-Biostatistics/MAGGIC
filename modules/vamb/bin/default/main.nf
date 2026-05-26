process VAMB_BIN_DEF {
    tag "${meta.id}"
    label 'process_low'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}vamb${params.fs}5.0.4" : null)
    conda (params.enable_conda ? "bioconda::vamb=5.0.4 conda-forge::bzip2" : null)
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/vamb:5.0.4--pyhdfd78af_0':
        'quay.io/biocontainers/vamb:5.0.4--pyhdfd78af_0' }"

    input:
        tuple val(meta), path(fasta), path(bam, stageAs: 'bam/*')

    output:
        tuple val(meta), path("${prefix}/bins/*.fna")         , emit: bins, optional: true
        tuple val(meta), path("${prefix}/*.npz")              , emit: npz, optional: true
        tuple val(meta), path("${prefix}/*.tsv")              , emit: tsv, optional: true
        tuple val(meta), path("${prefix}/model*")             , emit: model, optional: true
        tuple val(meta), path("${prefix}/*.txt")              , emit: txt, optional: true
        path "versions.yml"                                   , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args  = task.ext.args ?: ''
        def args2 = task.ext.args2 ?: ""
        prefix    = task.ext.prefix ?: "${meta.id}"
        """

        vamb bin default \\
            ${args} \\
            ${args2} \\
            --fasta ${fasta} \\
            --bamdir bam \\
            --outdir ${prefix} \\
            -p ${task.cpus} \\

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            vamb: \$( vamb --version | sed 's/Vamb //' )
        END_VERSIONS
        """
}