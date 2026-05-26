// Help text for coverm contig within CPIPES.

def covermcontigHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'coverm_contig_run': [
            clihelp: 'Run `coverm contig` tool. Default: ' +
                (params.coverm_contig_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'coverm_contig_mapper': [
            clihelp: 'Underlying mapping software used. Options: minimap2-sr, bwa-mem, bwa-mem2, ' +
                'minimap2-ont, minimap2-pb, minimap2-hifi, minimap2-no-preset. ' +
                "Default: ${params.coverm_contig_mapper}",
            cliflag: '--mapper',
            clivalue: (params.coverm_contig_mapper ?: 'minimap2-sr')
        ],
        'coverm_contig_minimap2_params': [
            clihelp: 'Extra parameters to provide to minimap2, both indexing command (if used) and for mapping. ' +
                "Default: ${params.coverm_contig_minimap2_params}",
            cliflag: '--minimap2-params',
            clivalue: (params.coverm_contig_minimap2_params ?: '')
        ],
        'coverm_contig_minimap2_reference_is_index': [
            clihelp: 'Treat reference as a minimap2 database, not as a FASTA file. ' +
                "Default: ${params.coverm_contig_minimap2_reference_is_index}",
            cliflag: '--minimap2-reference-is-index',
            clivalue: (params.coverm_contig_minimap2_reference_is_index ? ' ' : '')
        ],
        'coverm_contig_bwa_params': [
            clihelp: 'Extra parameters to provide to BWA or BWA-MEM2. ' +
                "Default: ${params.coverm_contig_bwa_params}",
            cliflag: '--bwa-params',
            clivalue: (params.coverm_contig_bwa_params ?: '')
        ],
        'coverm_contig_strobealign_params': [
            clihelp: 'Extra parameters to provide to strobealign. ' +
                "Default: ${params.coverm_contig_strobealign_params}",
            cliflag: '--strobealign-params',
            clivalue: (params.coverm_contig_strobealign_params ?: '')
        ],
        'coverm_contig_strobealign_use_index': [
            clihelp: 'Use a pregenerated index for strobealign. ' +
                "Default: ${params.coverm_contig_strobealign_use_index}",
            cliflag: '--strobealign-use-index',
            clivalue: (params.coverm_contig_strobealign_use_index ? ' ' : '')
        ],
        'coverm_contig_min_read_aligned_length': [
            clihelp: 'Exclude reads with smaller numbers of aligned bases. ' +
                "Default: ${params.coverm_contig_min_read_aligned_length}",
            cliflag: '--min-read-aligned-length',
            clivalue: (params.coverm_contig_min_read_aligned_length ?: '0')
        ],
        'coverm_contig_min_read_percent_identity': [
            clihelp: 'Exclude reads by overall percent identity e.g. 95 for 95%. ' +
                "Default: ${params.coverm_contig_min_read_percent_identity}",
            cliflag: '--min-read-percent-identity',
            clivalue: (params.coverm_contig_min_read_percent_identity ?: '0')
        ],
        'coverm_contig_min_read_aligned_percent': [
            clihelp: 'Exclude reads by percent aligned bases e.g. 95 means 95% of the read base. ' +
                "Default: ${params.coverm_contig_min_read_aligned_percent}",
            cliflag: '--min-read-aligned-percent',
            clivalue: (params.coverm_contig_min_read_aligned_percent ?: '0')
        ],
        'coverm_contig_min_read_aligned_length_pair': [
            clihelp: 'Exclude pairs with smaller numbers of aligned bases. Implies --proper-pairs-only. ' +
                "Default: ${params.coverm_contig_min_read_aligned_length_pair}",
            cliflag: '--min-read-aligned-length-pair',
            clivalue: (params.coverm_contig_min_read_aligned_length_pair ?: '0')
        ],
        'coverm_contig_min_read_percent_identity_pair': [
            clihelp: 'Exclude pairs by overall percent identity e.g. 95 for 95%. Implies --proper-pairs-only. ' +
                "Default: ${params.coverm_contig_min_read_percent_identity_pair}",
            cliflag: '--min-read-percent-identity-pair',
            clivalue: (params.coverm_contig_min_read_percent_identity_pair ?: '0')
        ],
        'coverm_contig_min_read_aligned_percent_pair': [
            clihelp: 'Exclude reads by percent aligned bases e.g. 95 means 95% of the read base. ' +
                "Default: ${params.coverm_contig_min_read_aligned_percent_pair}",
            cliflag: '--min-read-aligned-percent-pair',
            clivalue: (params.coverm_contig_min_read_aligned_percent_pair ?: '0')
        ],
        'coverm_contig_proper_pairs_only': [
            clihelp: 'Require reads to be mapped as proper pairs. ' +
                "Default: ${params.coverm_contig_proper_pairs_only}",
            cliflag: '--proper-pairs-only',
            clivalue: (params.coverm_contig_proper_pairs_only ? ' ' : '')
        ],
        'coverm_contig_exclude_supplementary': [
            clihelp: 'Exclude supplementary alignments. ' +
                "Default: ${params.coverm_contig_exclude_supplementary}",
            cliflag: '--exclude-supplementary',
            clivalue: (params.coverm_contig_exclude_supplementary ? ' ' : '')
        ],
        'coverm_contig_include_secondary': [
            clihelp: 'Include secondary alignments. ' +
                "Default: ${params.coverm_contig_include_secondary}",
            cliflag: '--include-secondary',
            clivalue: (params.coverm_contig_include_secondary ? ' ' : '')
        ],
        'coverm_contig_methods': [
            clihelp: 'Method(s) for calculating coverage. Options: mean, trimmed_mean, coverage_histogram, ' +
                'covered_bases, variance, length, count, metabat, reads_per_base, rpkm, tpm. ' +
                "Default: ${params.coverm_contig_methods}",
            cliflag: '--methods',
            clivalue: (params.coverm_contig_methods ?: 'mean')
        ],
        'coverm_contig_min_covered_fraction': [
            clihelp: 'Contigs with less covered bases than this are reported as having zero coverage. ' +
                "Default: ${params.coverm_contig_min_covered_fraction}",
            cliflag: '--min-covered-fraction',
            clivalue: (params.coverm_contig_min_covered_fraction ?: '0')
        ],
        'coverm_contig_contig_end_exclusion': [
            clihelp: 'Exclude bases at the ends of reference sequences from calculation. ' +
                "Default: ${params.coverm_contig_contig_end_exclusion}",
            cliflag: '--contig-end-exclusion',
            clivalue: (params.coverm_contig_contig_end_exclusion ?: '75')
        ],
        'coverm_contig_trim_min': [
            clihelp: 'Remove this smallest fraction of positions when calculating trimmed_mean. ' +
                "Default: ${params.coverm_contig_trim_min}",
            cliflag: '--trim-min',
            clivalue: (params.coverm_contig_trim_min ?: '5')
        ],
        'coverm_contig_trim_max': [
            clihelp: 'Maximum fraction for trimmed_mean calculations. ' +
                "Default: ${params.coverm_contig_trim_max}",
            cliflag: '--trim-max',
            clivalue: (params.coverm_contig_trim_max ?: '95')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}