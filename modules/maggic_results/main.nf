process MAGGIC_RESULTS {
    tag "${meta.id}"
    label "process_pico"

    module (params.enable_module ? "${params.swmodulepath}${params.fs}multiqc${params.fs}1.35" : null)
    conda (params.enable_conda ? "bioconda::multiqc=1.35 conda-forge::zstd" : null)
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/multiqc:1.35--pyhdfd78af_0' :
        'quay.io/biocontainers/multiqc:1.35--pyhdfd78af_0' }"

    input:
        tuple val(meta), path(gtdbtk_res), \
                path(genomad_res), \
                path(amrfinderplus_res), \
                path(coverm_res), \
                path(binette_res)

    output:
        tuple val(meta), path("maggic-results.tsv")                 , emit: results
        tuple val(meta), path("*-chromosome.tsv")                   , emit: chromosome_results
        tuple val(meta), path("*-plasmid.tsv")                      , emit: plasmid_results
        tuple val(meta), path("*-virus.tsv")                        , emit: virus_results
        tuple val(meta), path("maggic-globalabundance.tsv")         , emit: abundance
        tuple val(meta), path("ALL_REFINED_BINS_QUALITY_REPORT.tsv"), emit: binette_results
        path "*_mqc.yml"                                            , emit: mqc_yml
        path "versions.yml"                                         , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        """
        maggic_results.py \
            "." \
            -o maggic-results.tsv

        create_datasum_mqc.py maggic-results-datasum.json

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            python: \$( python --version | sed 's/Python //g' )
        END_VERSIONS
        """
}