process MINIMAP2_ALIGN {
    tag "$meta.id"
    label 'process_micro_turbo'

    module (params.enable_module ?
        "${params.swmodulepath}${params.fs}minimap2${params.fs}2.22:${params.swmodulepath}${params.fs}samtools${params.fs}1.13" : null)
    conda (params.enable_conda ? "bioconda::minimap2=2.28 bioconda::samtools=1.20 conda-forge::perl" : null)
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-66534bcbb7031a148b13e2ad42583020b9cd25c4:365b17b986c1a60c1b82c6066a9345f38317b763-0' :
        'quay.io/biocontainers/mulled-v2-66534bcbb7031a148b13e2ad42583020b9cd25c4:365b17b986c1a60c1b82c6066a9345f38317b763-0' }"

    input:
        tuple val(meta), path(reads), val(meta2), path(reference)

    output:
        tuple val(meta2), path("*.paf"), emit: paf, optional: true
        tuple val(meta2), path("*.bam"), emit: bam, optional: true
        tuple val(meta2), path("*.bai"), emit: bai, optional: true
        path "versions.yml"            , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def prefix = task.ext.prefix ?: "${meta2.id}_v_${meta.id}"
        def bam_output = "${params.minimap2_bam_format}" ? "-a | samtools sort | samtools view -@${task.cpus} -b -h -o ${prefix}.bam; samtools index -@${task.cpus} ${prefix}.bam" : "-o ${prefix}.paf"
        """
        minimap2 \\
            $args \\
            -t $task.cpus \\
            ${reference ?: reads} \\
            $reads \\
            $bam_output

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            minimap2: \$(minimap2 --version 2>&1)
            samtools: \$(samtools version | head -n1 | sed -e 's/samtools //' 2>&1)
        END_VERSIONS
    """
}