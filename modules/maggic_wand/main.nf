process MAGGIC_WAND {
    tag 'maggic-wand plots'
    label 'process_micro'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}maggic-wand${params.fs}0.1.2" : null)
    conda (params.enable_conda ? "conda-forge::python=3.11 conda-forge::uv conda-forge::pip" : null)
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container ?
        'oras://ghcr.io/biocoder/maggic-wand-sif:0.1.2' :
        'ghcr.io/biocoder/maggic-wand:0.1.2' }"

    input:
        tuple val(meta), path(results, stageAs: "maggic-results/*")

    output:
        path "*_mqc.png"           , emit: plots_mqc
        path "maggic-wand-plot.log", emit: log
        path "versions.yml"        , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def outputDir = task.ext.output_dir ?: '.'
        def maggieEnv = "${params.maggic_wand_env ?: '$HOME/.maggic-wand'}"
        def useContainer = workflow.containerEngine != null
        def envPrefix = useContainer ? '' : "UV_PROJECT_ENVIRONMENT=${maggieEnv} uv run "
        def logFile = 'maggic-wand-plot.log'
        """
        # Bootstrap: install maggic-wand if not present
        MAGGIC_ENV=${maggieEnv}
        MAGGIC_BIN="\${MAGGIC_ENV}/bin/maggic-wand"

        if ! command -v maggic-wand >/dev/null 2>&1 && [ ! -f "\${MAGGIC_BIN}" ]; then
            echo "[\$(date '+%Y-%m-%d %H:%M:%S')] Installing maggic-wand to \${MAGGIC_ENV}" | tee ${logFile}
            UV_PROJECT_ENVIRONMENT="\${MAGGIC_ENV}" uv pip install maggic-wand 2>&1 | tee -a ${logFile}
            echo "[\$(date '+%Y-%m-%d %H:%M:%S')] Installation complete" | tee -a ${logFile}
        else
            echo "[\$(date '+%Y-%m-%d %H:%M:%S')] maggic-wand already available" | tee ${logFile}
        fi

        ${envPrefix}maggic-wand plot \\
            -d maggic-results \\
            -o ${outputDir} \\
            2>&1 | tee -a ${logFile}

        for f in ${outputDir}/*.png; do
            [ -f "\$f" ] && mv "\$f" "\${f%.png}_mqc.png"
        done

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            maggic-wand: \$(${envPrefix}maggic-wand version 2>&1 | sed 's/\\x1b\\[[0-9;]*m//g; s/\\x1b\\]8;[^a]*a//g' | sed -n 's/.*v\\([0-9]\\+\\.\\([0-9]\\+\\.\\)\\+[0-9]\\+\\).*/\\1/p')
            python: \$( python --version | sed 's/Python //g' )
        END_VERSIONS
        """
}
