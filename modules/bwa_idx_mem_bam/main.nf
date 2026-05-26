process BWA_IDX_MEM_BAM {
    tag "$meta.id"
    label 'process_micro'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}bwa${params.fs}0.7.18" : null)
    conda (params.enable_conda ? "bioconda::bwa=0.7.18 bioconda::samtools=1.23 conda-forge::perl" : null)
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-fe8faa35dbf6dc65a0f7f5d4ea12e31a79f73e40:f45ad9036aa41bb10f875a330fa877d8869018a1-0' :
        'quay.io/biocontainers/mulled-v2-fe8faa35dbf6dc65a0f7f5d4ea12e31a79f73e40:f45ad9036aa41bb10f875a330fa877d8869018a1-0' }"

    input:
        tuple val(meta), path(genome), path(reads)
        val bam_format

    output:
        tuple val(meta), path("*.sam")       , emit: aligned_sam, optional: true
        tuple val(meta), path("*.sorted.bam"), emit: aligned_bam, optional: true
        path  "versions.yml"                 , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args   = task.ext.args ?: ''
        def args2  = task.ext.args2 ?: ''
        def prefix = task.ext.prefix ?: "${meta.id}"
        def bam_output = bam_format ? " | samtools view -@${task.cpus} -b -h | samtools sort @${task.cpus} -o ${prefix}.aligned.sorted.bam" : "> ${prefix}.aligned.sam"
        """
        bwa index $args $genome
        if [ "${params.fq_single_end}" = "false" ]; then
            bwa mem \\
                $args2 \\
                -t $task.cpus \\
                -a $genome \\
                ${reads[0]} ${reads[1]} $bam_output
        else
            bwa mem \\
                $args2 \\
                -t $task.cpus \\
                -a $genome \\
                $reads $bam_output

        fi

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            bwa: \$(echo \$(bwa 2>&1) | sed 's/^.*Version: //; s/Contact:.*\$//')
            samtools: \$(samtools version | head -n1 | sed -e 's/samtools //' 2>&1)
        END_VERSIONS
        """

}