process DREP_DEREPLICATE {
    tag "${meta.id}"
    label 'process_low'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}fastp${params.fs}0.23.2" : null)
    conda (params.enable_conda ? "bioconda::drep=3.6.2 conda-forge::pandas=2.3" : null)
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/drep:3.6.2--pyhdfd78af_0'
        : 'biocontainers/drep:3.6.2--pyhdfd78af_0'}"

    input:
        tuple val(meta), path(fastas, stageAs: 'input_fastas/*')
        tuple val(meta2), path(drep_work, stageAs: 'drep_work/')

    output:
        tuple val(meta), path("dereplicated_genomes/*"), emit: fastas
        tuple val(meta), path("data_tables/*.csv"), emit: summary_tables
        tuple val(meta), path("figures/*pdf"), emit: figures
        tuple val(meta), path("logger.log"), emit: log
        path "versions.yml", emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        """
        if [[ ! -d drep_work/ ]]; then
            mkdir drep_work/
        fi

        find -L input_fastas/ -type f > fastas_paths.txt

        dRep \\
            dereplicate \\
            drep_work/ \\
            -p ${task.cpus} \\
            -g fastas_paths.txt \\
            ${args} \\

        ## We copy the output files to copies to ensure we don't break an already
        ## existing drep_work/ from an upstream dRep module (e.g. compare)
        mkdir dereplicated_genomes/ figures/ data_tables
        cp drep_work/dereplicated_genomes/* dereplicated_genomes/
        cp drep_work/figures/* figures/
        cp drep_work/data_tables/* data_tables/
        cp drep_work/log/logger.log logger.log

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            drep: \$(dRep | head -n 2 | sed 's/.*v//g;s/ .*//g' | tail -n 1)
        END_VERSIONS
        """
}