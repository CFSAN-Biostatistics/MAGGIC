process METADECODER {
    tag "${meta.id}"
    label 'process_low'

    container "${params.metadecoder_container}"

    input:
        tuple val(meta), path(fasta), path(bam, stageAs: "bam/*")

    output:
        tuple val(meta), path("${prefix}_md_bins*.fasta"), emit: bins, optional: true
        path "versions.yml"                              , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def bamFiles = bam instanceof Path ? [bam] : bam.toList()
        def bamList = bamFiles.collect { bamFile -> bamFile.toString() }.join(' ')
        prefix = task.ext.prefix ?: "${meta.id}"
        """
        # Compute coverage from all BAMs
        metadecoder coverage \\
            --threads ${task.cpus} \\
            -b ${bamList} \\
            -o MMB \\
            ${args}

        # Train seed model on assembly
        metadecoder seed \\
            --threads ${task.cpus} \\
            -f ${fasta} \\
            -o MMS

        # Cluster into bins using coverage + seed model
        metadecoder cluster \\
            --threads ${task.cpus} \\
            -f ${fasta} \\
            -c MMB \\
            -s MMS \\
            -o ${prefix}_md_bins

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            metadecoder: \$( metadecoder --version 2>&1 | sed 's/metadecoder //' )
        END_VERSIONS
        """
}