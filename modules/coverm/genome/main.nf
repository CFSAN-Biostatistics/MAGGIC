process COVERM_GENOME {
    tag "${meta.id}"
    label "process_medium_turbo"

    module (params.enable_module ? "${params.swmodulepath}${params.fs}coverm${params.fs}0.7.0" : null)
    conda (params.enable_conda ? "bioconda::coverm=0.7.0 conda-forge::bzip2" : null)
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/coverm:0.7.0--hcb7b614_4' :
        'biocontainers/coverm:0.7.0--hcb7b614_4' }"

    input:
        tuple val(meta), path(reads_or_bam), val(meta2), path(reference, stageAs: 'final_bins/*'), path(quality_report)
        val bam_input
        val interleaved

    output:
        tuple val(meta), path("*.tsv"), emit: coverage
        path "versions.yml"           , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args          = task.ext.args ?: ""
        def prefix        = task.ext.prefix ?: "${meta.id}"
        def fastq_input   = meta.single_end ? "--single" : interleaved ? "--interleaved" : "--coupled"
        def input_type    = bam_input ? "--bam-files" : "${fastq_input}"
        """
        TMPDIR=.

        awk \
        -F'\\t' \
        'BEGIN{OFS="\\t"} \
        NR==1{print "Name","Completeness","Contamination","Completeness_Model_Used","Translation_Table_Used"} \
        NR>1{print \$1,\$5,\$6,\$8,"11"}' \
        ${quality_report} > quality_report_coverm.txt

        coverm genome \\
            ${args} \\
            --threads ${task.cpus} \\
            ${input_type} ${reads_or_bam} \\
            --genome-fasta-directory final_bins \\
            --checkm2-quality-report quality_report_coverm.txt \\
            --output-file ${prefix}.coverm.tsv

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            coverm: \$( coverm --version | sed 's/coverm //' )
        END_VERSIONS
        """
}