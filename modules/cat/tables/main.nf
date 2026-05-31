process TABLE_SUMMARY {
    tag "${meta.id}"
    label 'process_micro'

    module (params.enable_module ? "${params.swmodulepath}${params.fs}python${params.fs}3.12.5" : null)
    conda (params.enable_conda ? "conda-forge::python=3.12 conda-forge::pyyaml conda-forge::coreutils" : null)
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/multiqc:1.35--pyhdfd78af_0' :
        'quay.io/biocontainers/multiqc:1.35--pyhdfd78af_0' }"

    input:
        tuple val(meta), path(tables)

    output:
        tuple val(meta), path("*.tblsum.txt"), emit: tblsummed
        path "*_mqc.yml"                     , emit: mqc_yml
        path "versions.yml"                  , emit: versions

    when:
        task.ext.when == null || task.ext.when || tables

    script:
        def args = task.ext.args ?: ''
        def table_sum_on = "${meta.id}" ?: 'TBLSUM'
        def onthese = tables.collect().join('\\n')
        def color_args = ''

        if (table_sum_on == "${params.pipeline}-Results") {
            color_args = '--color-col Bacterial_Confidence --color-values "Bacterial_Confidence:High:#28a745;Bacterial_Confidence:Medium:#ffc107;Bacterial_Confidence:Low:#dc3545"'
        } else if (table_sum_on == "${params.pipeline}-Results-Chromosome") {
            color_args = '--color-col Bacterial_Confidence --color-values "Bacterial_Confidence:High:#28a745;Bacterial_Confidence:Medium:#ffc107;Bacterial_Confidence:Low:#dc3545"'
        } else if (table_sum_on == "${params.pipeline}-Results-Plasmid") {
            color_args = '--color-col Bacterial_Confidence,Plasmid_Signal_Uniformity --color-values "Bacterial_Confidence:High:#28a745;Bacterial_Confidence:Medium:#ffc107;Bacterial_Confidence:Low:#dc3545;Plasmid_Signal_Uniformity:High:#28a745;Plasmid_Signal_Uniformity:Medium:#ffc107;Plasmid_Signal_Uniformity:Low:#dc3545"'
        } else if (table_sum_on == "${params.pipeline}-Results-Virus") {
            color_args = '--color-col Virus_Signal_Uniformity --color-values "Virus_Signal_Uniformity:High:#28a745;Virus_Signal_Uniformity:Medium:#ffc107;Virus_Signal_Uniformity:Low:#dc3545"'
        }
        """
        filenum="1"
        header=""

        echo -e "$onthese" | while read -r file; do

            if [ "\${filenum}" == "1" ]; then
                header=\$( head -n1 "\${file}" )
                echo -e "\${header}" > ${table_sum_on}.tblsum.txt
            fi

            tail -n+2 "\${file}" | grep -vE '^\$' >> ${table_sum_on}.tblsum.txt || true

            filenum=\$((filenum+1))
        done

        create_mqc_data_table.py "$table_sum_on" $color_args

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            bash: \$( bash --version 2>&1 | sed '1!d; s/^.*version //; s/ (.*\$//' )
            python: \$( python --version | sed 's/Python //g' )
        END_VERSIONS

        headver=\$( head --version 2>&1 | sed '1!d; s/^.*(GNU coreutils//; s/) //;' )
        tailver=\$( tail --version 2>&1 | sed '1!d; s/^.*(GNU coreutils//; s/) //;' )

        cat <<-END_VERSIONS >> versions.yml
            head: \$headver
            tail: \$tailver
        END_VERSIONS
        """
}