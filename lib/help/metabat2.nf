// Help text for metabat2 within CPIPES.
def metabat2Help(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'metabat2_run': [
            clihelp: 'Run metabat2 binning tool. ',
            cliflag: null,
            clivalue: null
        ],
        'metabat2_min_contig': [
            clihelp: 'Minimum size of a contig for binning (should be >=1500). ',
            cliflag: '-m',
            clivalue: (params.metabat2_min_contig ?: '')
        ],
        'metabat2_min_small_contig': [
            clihelp: 'Minimum size of a small contig for recruiting into established bins ' +
                '(should be >=500). ',
            cliflag: '--minSmallContig',
            clivalue: (params.metabat2_min_small_contig ?: '')
        ],
        'metabat2_max_p': [
            clihelp: 'Percentage of good contigs considered for binning ' +
                '(should be between 1 and 99). Greater = more sensitive. ',
            cliflag: '--maxP',
            clivalue: (params.metabat2_max_p ?: '')
        ],
        'metabat2_min_s': [
            clihelp: 'Minimum score for binning ' +
                '(should be between 1 and 99). Greater = more specific. ',
            cliflag: '--minS',
            clivalue: (params.metabat2_min_s ?: '')
        ],
        'metabat2_max_edges': [
            clihelp: 'Maximum number of edges per node. Greater = more sensitive. ',
            cliflag: '--maxEdges',
            clivalue: (params.metabat2_max_edges ?: '')
        ],
        'metabat2_p_tnf': [
            clihelp: 'TNF probability cutoff for building TNF graph. ' +
                'Use %% value between 1 and 100 to skip auto preparation step. (0: auto). ',
            cliflag: '--pTNF',
            clivalue: (params.metabat2_p_tnf ?: '')
        ],
        'metabat2_no_add': [
            clihelp: 'Turning off additional binning for lost or small contigs. ',
            cliflag: '--noAdd',
            clivalue: (params.metabat2_no_add ? ' ' : '')
        ],
        'metabat2_min_recruiting_size': [
            clihelp: 'Minimum cluster size for recruiting of small and leftover contigs ' +
                '(if not noAdd). ',
            cliflag: '--minRecruitingSize',
            clivalue: (params.metabat2_min_recruiting_size ?: '')
        ],
        'metabat2_recruit_to_abd_centroid': [
            clihelp: '[EXPERIMENTAL] If set (and not noAdd), use the weighted-by-abundance ' +
                'centroid of a cluster to recruit small and lost contigs. ' +
                'Potentially reduces sensitivity and improves speed. ',
            cliflag: '--recruitToAbdCentroid',
            clivalue: (params.metabat2_recruit_to_abd_centroid ? ' ' : '')
        ],
        'metabat2_recruit_with_tnf': [
            clihelp: '[EXPERIMENTAL] If non-zero (and not noAdd), uses this factor against the ' +
                'large-contig TNF threshold to require small and lost contigs have at least that TNF ' +
                'distance from the centroid of the recruiting cluster. Recommend 0.9-1.0. ',
            cliflag: '--recruitWithTNF',
            clivalue: (params.metabat2_recruit_with_tnf ?: '')
        ],
        'metabat2_full_header': [
            clihelp: 'Preserve full FASTA headers from input assembly ' +
                '(default: trim at first space). ',
            cliflag: '--fullHeader',
            clivalue: (params.metabat2_full_header ? ' ' : '')
        ],
        'metabat2_min_cv': [
            clihelp: 'Minimum mean coverage of a contig in each library for binning. ',
            cliflag: '-x',
            clivalue: (params.metabat2_min_cv ?: '')
        ],
        'metabat2_min_cv_sum': [
            clihelp: 'Minimum total effective mean coverage of a contig ' +
                '(sum of depth over minCV) for binning. ',
            cliflag: '--minCVSum',
            clivalue: (params.metabat2_min_cv_sum ?: '')
        ],
        'metabat2_min_cls_size': [
            clihelp: 'Minimum size of a bin as the output. ',
            cliflag: '-s',
            clivalue: (params.metabat2_min_cls_size ?: '')
        ],
        'metabat2_only_label': [
            clihelp: 'Output only sequence labels as a list in a column without sequences. ',
            cliflag: '--onlyLabel',
            clivalue: (params.metabat2_only_label ? ' ' : '')
        ],
        'metabat2_save_cls': [
            clihelp: 'Save cluster memberships as a matrix format. ',
            cliflag: '--saveCls',
            clivalue: (params.metabat2_save_cls ? ' ' : '')
        ],
        'metabat2_unbinned': [
            clihelp: 'Generate [outFile].unbinned.fa file for unbinned contigs. ',
            cliflag: '--unbinned',
            clivalue: (params.metabat2_unbinned ? ' ' : '')
        ],
        'metabat2_no_bin_out': [
            clihelp: 'No bin output. Usually combined with --saveCls to check ' +
                'only contig memberships. ',
            cliflag: '--noBinOut',
            clivalue: (params.metabat2_no_bin_out ? ' ' : '')
        ],
        'metabat2_no_sample_depths': [
            clihelp: 'Do not include per-sample depths in bin fasta headers. ',
            cliflag: '--noSampleDepths',
            clivalue: (params.metabat2_no_sample_depths ? ' ' : '')
        ],
        'metabat2_seed': [
            clihelp: 'For exact reproducibility. (0: use random seed). ',
            cliflag: '--seed',
            clivalue: (params.metabat2_seed ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}