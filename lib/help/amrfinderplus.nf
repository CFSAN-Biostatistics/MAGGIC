def amrfinderplusHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'amrfinderplus_run': [
            clihelp: "Run AMRFinderPlus tool. Default: ${params.amrfinderplus_run}",
            cliflag: null,
            clivalue: null
        ],
        'amrfinderplus_db': [
            clihelp: 'Path to AMRFinderPlus database. Please note that ' +
                ' the databases should be ready and formatted with blast for use. ' +
                'Please read more at: ' +
                'https://github.com/ncbi/amr/wiki/AMRFinderPlus-database ' +
                "Default: ${params.amrfinderplus_db}",
            cliflag: '--database',
            clivalue: (params.amrfinderplus_db ?: '')
        ],
        'amrfinderplus_genes': [
            clihelp: 'Add the plus genes to the report. ' +
                "Default: ${params.amrfinderplus_genes}",
            cliflag: '--plus',
            clivalue: (params.amrfinderplus_genes ? ' ' : '')
        ],
        'amrfinderplus_protein_output': [
            clihelp: 'Output protein FASTA file of reported proteins. ' +
                "Default: ${params.amrfinderplus_protein_output}",
            cliflag: '--protein_output',
            clivalue: (params.amrfinderplus_protein_output ?: '')
        ],
        'amrfinderplus_nucleotide_output': [
            clihelp: 'Output nucleotide FASTA file of reported nucleotide sequences. ' +
                "Default: ${params.amrfinderplus_nucleotide_output}",
            cliflag: '--nucleotide_output',
            clivalue: (params.amrfinderplus_nucleotide_output ?: '')
        ],
        'amrfinderplus_nucleotide_flank5_output': [
            clihelp: 'Output nucleotide FASTA file of reported nucleotide sequences with 5\' flanking sequences. ' +
                "Default: ${params.amrfinderplus_nucleotide_flank5_output}",
            cliflag: '--nucleotide_flank5_output',
            clivalue: (params.amrfinderplus_nucleotide_flank5_output ?: '')
        ],
        'amrfinderplus_nucleotide_flank5_size': [
            clihelp: '5\' flanking sequence size for nucleotide_flank5_output. ' +
                "Default: ${params.amrfinderplus_nucleotide_flank5_size}",
            cliflag: '--nucleotide_flank5_size',
            clivalue: (params.amrfinderplus_nucleotide_flank5_size ?: '')
        ],
        'amrfinderplus_translation_table': [
            clihelp: 'NCBI genetic code for translated BLAST. ' +
                "Default: ${params.amrfinderplus_translation_table}",
            cliflag: '--translation_table',
            clivalue: (params.amrfinderplus_translation_table ?: '')
        ],
        'amrfinderplus_report_common': [
            clihelp: 'Report proteins common to a taxonomy group. ' +
                "Default: ${params.amrfinderplus_report_common}",
            cliflag: '--report_common',
            clivalue: (params.amrfinderplus_report_common ? ' ' : '')
        ],
        'amrfinderplus_report_all_equal': [
            clihelp: 'Report all equally-scoring BLAST and HMM matches. ' +
                "Default: ${params.amrfinderplus_report_all_equal}",
            cliflag: '--report_all_equal',
            clivalue: (params.amrfinderplus_report_all_equal ? ' ' : '')
        ],
        'amrfinderplus_ident_min': [
            clihelp: 'Minimum proportion of identical amino acids in alignment for hit (0..1). ' +
                '-1 means use curated threshold if it exists and 0.9 otherwise. ' +
                "Default: ${params.amrfinderplus_ident_min}",
            cliflag: '--ident_min',
            clivalue: (params.amrfinderplus_ident_min ?: '')
        ],
        'amrfinderplus_coverage_min': [
            clihelp: 'Minimum coverage of the reference protein (0..1). ' +
                "Default: ${params.amrfinderplus_coverage_min}",
            cliflag: '--coverage_min',
            clivalue: (params.amrfinderplus_coverage_min ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}