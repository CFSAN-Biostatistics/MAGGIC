process MULTIQC {
    tag 'multiqc'
    label 'process_micro'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}multiqc${params.fs}1.35" : null)
    conda (params.enable_conda ? "bioconda::multiqc=1.35 conda-forge::zstd" : null)
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/multiqc:1.35--pyhdfd78af_0' :
        'quay.io/biocontainers/multiqc:1.35--pyhdfd78af_0' }"

    input:
        path(results_dirs)

    output:
        path "*multiqc*"
        path "*multiqc_report.html", emit: report
        path "*_data"              , emit: data
        path "*_plots"             , emit: plots, optional: true
        path "versions.yml"        , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        """
        cp ${params.projectconf}${params.fs}multiqc${params.fs}${params.pipeline}_mqc.yml cpipes_mqc_config.yml
        sed -i -e 's/Workflow_Name_Placeholder/${params.pipeline}/g; s/Workflow_Version_Placeholder/${params.workflow_version}/g' cpipes_mqc_config.yml
        sed -i -e 's/CPIPES_Version_Placeholder/${workflow.manifest.version}/g; s|Workflow_Output_Placeholder|${params.output}|g' cpipes_mqc_config.yml
        sed -i -e 's|Workflow_Input_Placeholder|${params.input}|g' cpipes_mqc_config.yml

        if [ -n "\$(ls *filtlong.log 2> /dev/null)" ]; then
            sed -i -e 's%,%%g' *filtlong.log
        fi

        multiqc --interactive -c cpipes_mqc_config.yml --no-ai -f $args .

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            multiqc: \$( multiqc --version 2>&1 | sed 's/multiqc version //' )
        END_VERSIONS
        """
}