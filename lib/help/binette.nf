// Help text for binette within CPIPES.

def binetteHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'binette_run': [
            clihelp: 'Run Binette bin refinement tool. Default: ' +
                (params.binette_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'binette_checkm2_db': [
            clihelp: 'Path to CheckM2 uniref100.KO.1.dmnd database. ' +
                "Default: ${params.binette_checkm2_db}",
            cliflag: '--checkm2_db',
            clivalue: (params.binette_checkm2_db ?: '')
        ],
        'binette_min_bin_size': [
            clihelp: 'Minimum bin size to keep (default=250000). ' +
                "Default: ${params.binette_min_bin_size}",
            cliflag: '--min_bin_size',
            clivalue: (params.binette_min_bin_size ?: '')
        ],
        'binette_max_completeness': [
            clihelp: 'Maximum completeness to keep a bin (default=120). ' +
                "Default: ${params.binette_max_completeness}",
            cliflag: '--max_completeness',
            clivalue: (params.binette_max_completeness ?: '')
        ],
        'binette_max_contamination': [
            clihelp: 'Maximum contamination to keep a bin (default=51). ' +
                "Default: ${params.binette_max_contamination}",
            cliflag: '--max_contamination',
            clivalue: (params.binette_max_contamination ?: '')
        ],
        'binette_min_completeness': [
            clihelp: 'Minimum completeness to keep a bin (default=20). ' +
                "Default: ${params.binette_min_completeness}",
            cliflag: '--min_completeness',
            clivalue: (params.binette_min_completeness ?: '')
        ],
        'binette_min_contamination': [
            clihelp: 'Minimum contamination to keep a bin (default=0). ' +
                "Default: ${params.binette_min_contamination}",
            cliflag: '--min_contamination',
            clivalue: (params.binette_min_contamination ?: '')
        ],
        'binette_mode': [
            clihelp: 'Binette mode: default or sensitive (default=default). ' +
                "Default: ${params.binette_mode}",
            cliflag: '--mode',
            clivalue: (params.binette_mode ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}