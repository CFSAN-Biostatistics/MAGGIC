// Help text for gtdbtk classify_wf within CPIPES.

def gtdbtkclassifywfHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'gtdbtk_classify_wf_run': [
            clihelp: 'Run GTDB-Tk classify_wf tool. Default: ' +
                (params.gtdbtk_classify_wf_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'gtdbtk_classify_wf_place_species': [
            clihelp: 'Place species in pplacer trees even if they are classified with skani. ' +
                "Default: ${params.gtdbtk_classify_wf_place_species}",
            cliflag: '--place_species',
            clivalue: params.gtdbtk_classify_wf_place_species ? ' ' : ''
        ],
        'gtdbtk_classify_wf_x': [
            clihelp: 'Extension of files to process, gz = gzipped. ' +
                "Default: ${params.gtdbtk_classify_wf_x}",
            cliflag: '-x',
            clivalue: params.gtdbtk_classify_wf_x ?: ''
        ],
        'gtdbtk_classify_wf_min_perc_aa': [
            clihelp: 'Exclude genomes that do not have at least this percentage of AA in the MSA (inclusive bound). ' +
                "Default: ${params.gtdbtk_classify_wf_min_perc_aa}",
            cliflag: '--min_perc_aa',
            clivalue: params.gtdbtk_classify_wf_min_perc_aa ?: ''
        ],
        'gtdbtk_classify_wf_genes': [
            clihelp: 'Indicates input files contain predicted proteins as amino acids (skip gene calling). ' +
                "Default: ${params.gtdbtk_classify_wf_genes}",
            cliflag: '--genes',
            clivalue: params.gtdbtk_classify_wf_genes ? ' ' : ''
        ],
        'gtdbtk_classify_wf_force': [
            clihelp: 'Continue processing if an error occurs on a single genome. ' +
                "Default: ${params.gtdbtk_classify_wf_force}",
            cliflag: '--force',
            clivalue: params.gtdbtk_classify_wf_force ? ' ' : ''
        ],
        'gtdbtk_classify_wf_scratch_dir': [
            clihelp: 'Reduce pplacer memory usage by writing to disk (slower). ' +
                "Default: ${params.gtdbtk_classify_wf_scratch_dir}",
            cliflag: '--scratch_dir',
            clivalue: params.gtdbtk_classify_wf_scratch_dir ?: ''
        ],
        'gtdbtk_classify_wf_write_single_copy_genes': [
            clihelp: 'Output unaligned single-copy marker genes. ' +
                "Default: ${params.gtdbtk_classify_wf_write_single_copy_genes}",
            cliflag: '--write_single_copy_genes',
            clivalue: params.gtdbtk_classify_wf_write_single_copy_genes ? ' ' : ''
        ],
        'gtdbtk_classify_wf_keep_intermediates': [
            clihelp: 'Keep intermediate files in the final directory. ' +
                "Default: ${params.gtdbtk_classify_wf_keep_intermediates}",
            cliflag: '--keep_intermediates',
            clivalue: params.gtdbtk_classify_wf_keep_intermediates ? ' ' : ''
        ],
        'gtdbtk_classify_wf_min_af': [
            clihelp: 'Minimum alignment fraction to assign genome to a species cluster. ' +
                "Default: ${params.gtdbtk_classify_wf_min_af}",
            cliflag: '--min_af',
            clivalue: params.gtdbtk_classify_wf_min_af ?: ''
        ],
        'gtdbtk_classify_wf_debug': [
            clihelp: 'Create intermediate files for debugging purposes. ' +
                "Default: ${params.gtdbtk_classify_wf_debug}",
            cliflag: '--debug',
            clivalue: params.gtdbtk_classify_wf_debug ? ' ' : ''
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}