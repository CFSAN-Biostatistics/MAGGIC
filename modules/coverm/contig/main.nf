process COVERM_CONTIG {
    tag "${meta.id}"
    label "process_low"

    module (params.enable_module ? "${params.swmodulepath}${params.fs}coverm${params.fs}0.7.0" : null)
    conda (params.enable_conda ? "bioconda::coverm=0.7.0 conda-forge::bzip2" : null)
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/coverm:0.7.0--hcb7b614_4' :
        'biocontainers/coverm:0.7.0--hcb7b614_4' }"

    input:
        tuple val(meta), path(reference), path(input)
        val bam_input
        val interleaved

    output:
        tuple val(meta), path("*.depth.txt"), emit: coverage

    when:
        task.ext.when == null || task.ext.when

    script:
        def args          = task.ext.args ?: ""
        def prefix        = task.ext.prefix ?: "${meta.id}"
        def fastq_input   = meta.single_end ? "--single" : interleaved ? "--interleaved" : "--coupled"
        def input_type    = bam_input ? "--bam-files" : "${fastq_input}"
        def reference_str = bam_input ? "" : "--reference ${reference}"
        """
        TMPDIR=.

        coverm contig \\
            --threads ${task.cpus} \\
            ${input_type} ${input} \\
            ${reference_str} \\
            ${args} \\
            --output-file ${prefix}.depth.txt

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            coverm: \$( coverm --version | sed 's/coverm //' )
        END_VERSIONS
        """
}