// Help text for skani search within CPIPES.

def skanisearchHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'skanisearch_run': [
            clihelp: 'Run `skani search` tool. Default: ' +
                (params.skanisearch_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'skanisearch_qi': [
            clihelp: "Use individual sequences for the QUERY in a multi-line FASTA. " +
                "Default: ${params.skanisearch_qi}",
            cliflag: '--qi',
            clivalue: (params.skanisearch_qi ? ' ' : '')
        ],
        'skanisearch_both_min_af': [
            clihelp: 'Only output ANI values where both genomes have aligned fraction ' +
                'greater than this value. ' +
                "Default: ${params.skanisearch_both_min_af}",
            cliflag: '--both-min-af',
            clivalue: (params.skanisearch_both_min_af ? ' ' : '')
        ],
        'skanisearch_ci': [
            clihelp: 'Output [5%,95%] ANI confidence intervals using percentile ' +
                'bootstrap on the putative ANI distribution. ' +
                "Default: ${params.skanisearch_ci}",
            cliflag: '--ci',
            clivalue: (params.skanisearch_ci ? ' ' : '')
        ],
        'skanisearch_detailed': [
            clihelp: 'Print additional info including contig N50s and more. ' +
                "Default: ${params.skanisearch_detailed}",
            cliflag: '--detailed',
            clivalue: (params.skanisearch_detailed ? ' ' : '')
        ],
        'skanisearch_min_af': [
            clihelp: 'Only output ANI values where one genome has aligned fraction ' +
                'greater than this value. ' +
                "Default: ${params.skanisearch_min_af}",
            cliflag: '--min-af',
            clivalue: (params.skanisearch_min_af ?: '')
        ],
        'skanisearch_n': [
            clihelp: 'Max number of results to show for each query. ' +
                "Default: ${params.skanisearch_n}",
            cliflag: '-n',
            clivalue: (params.skanisearch_n ?: '')
        ],
        'skanisearch_keep_refs': [
            clihelp: 'Keep reference sketches in memory if the sketch passes the ' +
                'marker filter. Takes more memory but is much faster when querying ' +
                'many similar sequences' +
                "Default: ${params.skanisearch_keep_refs}",
            cliflag: '--keep-refs',
            clivalue: (params.skanisearch_keep_refs ? ' ' : '')
        ],
        'skanisearch_median': [
            clihelp: 'Estimate median identity instead of average (mean) identity. ' +
                "Default: ${params.skanisearch_median}",
            cliflag: '--median',
            clivalue: (params.skanisearch_median ? ' ' : '')
        ],
        'skanisearch_median': [
            clihelp: 'Estimate median identity instead of average (mean) identity. ' +
                "Default: ${params.skanisearch_median}",
            cliflag: '--median',
            clivalue: (params.skanisearch_median ? ' ' : '')
        ],
        'skanisearch_median': [
            clihelp: 'Estimate median identity instead of average (mean) identity. ' +
                "Default: ${params.skanisearch_median}",
            cliflag: '--median',
            clivalue: (params.skanisearch_median ? ' ' : '')
        ],
        'skanisearch_no_learn_ani': [
            clihelp: 'Disable regression model for ANI prediction. ' +
                "Default: ${params.skanisearch_no_learn_ani}",
            cliflag: '--no-learned-ani',
            clivalue: (params.skanisearch_no_learn_ani ? ' ' : '')
        ],
        'skanisearch_no_marker_idx': [
            clihelp: 'Do not use hash-table inverted index for faster ANI filtering. ' +
                "Default: ${params.skanisearch_no_marker_idx}",
            cliflag: '--no-marker-index',
            clivalue: (params.skanisearch_no_marker_idx ? ' ' : '')
        ],
        'skanisearch_robust': [
            clihelp: 'Estimate mean after trimming off 10%/90% quantiles. ' +
                "Default: ${params.skanisearch_robust}",
            cliflag: '--robust',
            clivalue: (params.skanisearch_robust ? ' ' : '')
        ],
        'skanisearch_s': [
            clihelp: 'Screen out pairs with *approximately* < % identity using k-mer ' +
                'sketching. ' +
                "Default: ${params.skanisearch_s}",
            cliflag: '--s',
            clivalue: (params.skanisearch_s ?: '')
        ],
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}