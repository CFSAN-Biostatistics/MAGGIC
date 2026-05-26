// Help text for coverm cluster within CPIPES.

def covermclusterHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'coverm_cluster_run': [
            clihelp: 'Run `coverm cluster` tool. Default: ' +
                (params.coverm_cluster_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'coverm_cluster_checkm2_quality_report': [
            clihelp: 'CheckM2 quality_report.tsv for defining genome quality, used for filtering and ranking during clustering. ' +
                "Default: ${params.coverm_cluster_checkm2_quality_report}",
            cliflag: '--checkm2-quality-report',
            clivalue: (params.coverm_cluster_checkm2_quality_report ?: '')
        ],
        'coverm_cluster_min_completeness': [
            clihelp: 'Ignore genomes with less completeness than this percentage. ' +
                "Default: ${params.coverm_cluster_min_completeness}",
            cliflag: '--min-completeness',
            clivalue: (params.coverm_cluster_min_completeness ?: '0')
        ],
        'coverm_cluster_max_contamination': [
            clihelp: 'Ignore genomes with more contamination than this percentage. ' +
                "Default: ${params.coverm_cluster_max_contamination}",
            cliflag: '--max-contamination',
            clivalue: (params.coverm_cluster_max_contamination ?: '100')
        ],
        'coverm_cluster_ani': [
            clihelp: 'Overall ANI level to dereplicate at with FastANI. ' +
                "Default: ${params.coverm_cluster_ani}",
            cliflag: '--ani',
            clivalue: (params.coverm_cluster_ani ?: '95')
        ],
        'coverm_cluster_min_aligned_fraction': [
            clihelp: 'Min aligned fraction of two genomes for clustering. ' +
                "Default: ${params.coverm_cluster_min_aligned_fraction}",
            cliflag: '--min-aligned-fraction',
            clivalue: (params.coverm_cluster_min_aligned_fraction ?: '15')
        ],
        'coverm_cluster_fragment_length': [
            clihelp: 'Length of fragment used in FastANI calculation. ' +
                "Default: ${params.coverm_cluster_fragment_length}",
            cliflag: '--fragment-length',
            clivalue: (params.coverm_cluster_fragment_length ?: '3000')
        ],
        'coverm_cluster_quality_formula': [
            clihelp: 'Scoring function for genome quality. Options: Parks2020_reduced, completeness-4contamination, completeness-5contamination, dRep. ' +
                "Default: ${params.coverm_cluster_quality_formula}",
            cliflag: '--quality-formula',
            clivalue: (params.coverm_cluster_quality_formula ?: 'Parks2020_reduced')
        ],
        'coverm_cluster_precluster_ani': [
            clihelp: 'Require at least this dashing-derived ANI for preclustering. ' +
                "Default: ${params.coverm_cluster_precluster_ani}",
            cliflag: '--precluster-ani',
            clivalue: (params.coverm_cluster_precluster_ani ?: '90')
        ],
        'coverm_cluster_precluster_method': [
            clihelp: 'Method for rough ANI calculation. Options: dashing, finch, skani. ' +
                "Default: ${params.coverm_cluster_precluster_method}",
            cliflag: '--precluster-method',
            clivalue: (params.coverm_cluster_precluster_method ?: 'skani')
        ],
        'coverm_cluster_method': [
            clihelp: 'Method for ANI calculation. Options: fastani, skani. ' +
                "Default: ${params.coverm_cluster_method}",
            cliflag: '--cluster-method',
            clivalue: (params.coverm_cluster_method ?: 'skani')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}