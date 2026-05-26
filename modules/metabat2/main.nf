process METABAT2 {
    tag "$meta.id"
    label 'process_low_turbo'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}metabat2${params.fs}2.18_23_gc869c52--h61f4f8f" : null)
    conda (params.enable_conda ? "bioconda::metabat2=2.18_23_gc869c52 conda-forge::zstd" : null)
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/metabat2:2.18_23_gc869c52--h61f4f8f_0' :
        'quay.io/biocontainers/metabat2:2.18_23_gc869c52--h61f4f8f_0' }"

    input:
        tuple val(meta), path(fasta), path(bam, stageAs: "bam/*"), path(bai, stageAs: "bam/*")

    output:
        tuple val(meta), path("${prefix}_mb_bins*.fa"), emit: bins, optional: true
        path "versions.yml"                           , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        prefix = task.ext.prefix ?: "${meta.id}"

        """
        TMPDIR=.

        # Generate contig depth table from BAM files
        jgi_summarize_bam_contig_depths \\
            --outputDepth ${prefix}.tab \\
            --referenceFasta ${fasta} \\
            ./bam/*.bam

        # Run metabat2 binning
        metabat2 \\
            $args \\
            -t ${task.cpus} \\
            -o ${prefix}_mb_bins \\
            -i ${fasta} \\
            -a ${prefix}.tab

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            metabat2: \$(metabat2 --help 2>&1 | sed -n "2s/.*:\\([0-9]*\\.[0-9]*\\).*/\\1/p")
        END_VERSIONS
        """
}