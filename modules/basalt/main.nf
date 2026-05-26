process BASALT_BIN_REFINE {
    tag "${meta.id}"
    label 'process_low'

    container "${params.basalt_container}"

    input:
        tuple val(meta), path(assembly), path(bam, stageAs: "bam/*")

    output:
        tuple val(meta), path("output_bins/**"), emit: bins
        path "versions.yml"                    , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def prefix = task.ext.prefix ?: "${meta.id}"
        """
        basalt bin refine \
            --input ${assembly} \
            --bam ${bam} \
            --output ${prefix} \
            --cpus ${task.cpus} \
            ${args}

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            basalt: \$( basalt --version 2>&1 || echo 'unknown' )
        END_VERSIONS
        """
}