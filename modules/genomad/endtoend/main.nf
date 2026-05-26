process GENOMAD_ENDTOEND {
    tag "${meta.id}"
    label 'process_micro'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}genomad${params.fs}1.12.0" : null)
    conda (params.enable_conda ? "bioconda::genomad=1.12.0 conda-forge::bzip2" : null)
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/genomad:1.12.0--pyhdfd78af_0'
        : 'quay.io/biocontainers/genomad:1.12.0--pyhdfd78af_0' }"

    input:
        tuple val(meta), path(fasta)
        path genomad_db

    output:
        tuple val(meta), path("${prefix}${params.fs}*_aggregated_classification/*_aggregated_classification.tsv")   , emit: aggregated_classification, optional: true
        tuple val(meta), path("${prefix}${params.fs}*_marker_classification/*_marker_classification.tsv")           , emit: marker_classification, optional: true
        tuple val(meta), path("${prefix}${params.fs}*_annotate/*_taxonomy.tsv")                                     , emit: taxonomy
        tuple val(meta), path("${prefix}${params.fs}*_find_proviruses/*_provirus.tsv")                              , emit: provirus
        tuple val(meta), path("${prefix}${params.fs}*_score_calibration/*_compositions.tsv")                        , emit: compositions, optional: true
        tuple val(meta), path("${prefix}${params.fs}*_score_calibration/*_calibrated_aggregated_classification.tsv"), emit: calibrated_classification, optional: true
        tuple val(meta), path("${prefix}${params.fs}*_summary/*_plasmid.fna.gz")                                    , emit: plasmid_fasta
        tuple val(meta), path("${prefix}${params.fs}*_summary/*_plasmid_genes.tsv")                                 , emit: plasmid_genes
        tuple val(meta), path("${prefix}${params.fs}*_summary/*_plasmid_proteins.faa.gz")                           , emit: plasmid_proteins
        tuple val(meta), path("${prefix}${params.fs}*_summary/*_plasmid_summary.tsv")                               , emit: plasmid_summary
        tuple val(meta), path("${prefix}${params.fs}*_summary/*_virus.fna.gz")                                      , emit: virus_fasta
        tuple val(meta), path("${prefix}${params.fs}*_summary/*_virus_genes.tsv")                                   , emit: virus_genes
        tuple val(meta), path("${prefix}${params.fs}*_summary/*_virus_proteins.faa.gz")                             , emit: virus_proteins
        tuple val(meta), path("${prefix}${params.fs}*_summary/*_virus_summary.tsv")                                 , emit: virus_summary
        path "versions.yml"                                                                                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        prefix = task.ext.prefix ?: "${meta.id}"
        """
        genomad \\
            end-to-end \\
            ${fasta} \\
            ${prefix} \\
            ${genomad_db} \\
            --threads ${task.cpus} \\
            ${args}

        find . -mindepth 2 -name '*.fna' -exec gzip {} +
        find . -mindepth 2 -name '*.faa' -exec gzip {} +

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            genomad: \$( genomad --version 2>&1 | sed 's/^.*geNomad, version //; s/ .*//' )
        END_VERSIONS
        """
}