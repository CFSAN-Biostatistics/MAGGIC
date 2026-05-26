// Help text for semibin2 within CPIPES.

def semibin2mebHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'semibin2_single_easy_bin_run': [
            clihelp: 'Run SemiBin2 single_easy_bin tool. Default: ' +
                (params.semibin2_multi_easy_bin_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'semibin2_abundance': [
            clihelp: 'Path to the abundance file from strobealign-aemb. ' +
                'This can only be used when samples used in binning above or equal 5. ' +
                "Default: ${params.semibin2_abundance}",
            cliflag: '-a',
            clivalue: (params.semibin2_abundance ? ' ' : '')
        ],
        'semibin2_write_pre_reclustering_bins': [
            clihelp: 'Write pre-reclustering bins to disk. ' +
                "Default: ${params.semibin2_write_pre_reclustering_bins}",
            cliflag: '--write-pre-reclustering-bins',
            clivalue: (params.semibin2_write_pre_reclustering_bins ? ' ' : '')
        ],
        'semibin2_no_write_pre_reclustering_bins': [
            clihelp: 'Do not write pre-reclustering bins to disk. ' +
                "Default: ${params.semibin2_no_write_pre_reclustering_bins}",
            cliflag: '--no-write-pre-reclustering-bins',
            clivalue: (params.semibin2_no_write_pre_reclustering_bins ? ' ' : '')
        ],
        'semibin2_tag_output': [
            clihelp: 'Tag to add to output file names. ' +
                "Default: ${params.semibin2_tag_output}",
            cliflag: '--tag-output',
            clivalue: (params.semibin2_tag_output ?: '')
        ],
        'semibin2_compression': [
            clihelp: 'Compression type for the output files ' +
                '(accepted values: gz [default]/xz/bz2/none). ' +
                "Default: ${params.semibin2_compression}",
            cliflag: '--compression',
            clivalue: (params.semibin2_compression ?: '')
        ],
        'semibin2_orf_finder': [
            clihelp: 'ORF finder used to estimate the number of bins ' +
                '(fast-naive/prodigal/fraggenescan). ' +
                "Default: ${params.semibin2_orf_finder}",
            cliflag: '--orf-finder',
            clivalue: (params.semibin2_orf_finder ?: '')
        ],
        'semibin2_prodigal_output_faa': [
            clihelp: '[deprecated] Bypasses ORF calling and uses the provided .faa file instead ' +
                '(must be in same format as prodigal output). ' +
                "Default: ${params.semibin2_prodigal_output_faa}",
            cliflag: '--prodigal-output-faa',
            clivalue: (params.semibin2_prodigal_output_faa ?: '')
        ],
        'semibin2_tmpdir': [
            clihelp: 'Option to set temporary directory. ' +
                "Default: ${params.semibin2_tmpdir}",
            cliflag: '--tmpdir',
            clivalue: (params.semibin2_tmpdir ?: '')
        ],
        'semibin2_processes': [
            clihelp: 'Number of CPUs used (pass the value 0 to use all CPUs, default: 0). ' +
                "Default: ${params.semibin2_processes}",
            cliflag: '-p',
            clivalue: (params.semibin2_processes ? ' ' : '')
        ],
        'semibin2_threads': [
            clihelp: 'Number of CPUs used (pass the value 0 to use all CPUs, default: 0). ' +
                "Default: ${params.semibin2_threads}",
            cliflag: '-t',
            clivalue: (params.semibin2_threads ? ' ' : '')
        ],
        'semibin2_min_len': [
            clihelp: 'Minimal length for contigs in binning. ' +
                'If you use SemiBin with multi steps and you use this parameter, ' +
                'please use this parameter consistently with all subcommands. ' +
                '(Default: SemiBin chooses 1000bp or 2500bp according the ratio of the number of base pairs ' +
                'of contigs between 1000-2500bp). ' +
                "Default: ${params.semibin2_min_len}",
            cliflag: '-m',
            clivalue: (params.semibin2_min_len ?: '')
        ],
        'semibin2_ratio': [
            clihelp: 'If the ratio of the number of base pairs of contigs between 1000-2500 bp smaller than this value, ' +
                'the minimal length will be set as 1000bp, otherwise 2500bp. ' +
                'Note that setting `--min-length/-m` overrules this parameter. ' +
                'If you use SemiBin with multi steps and you use this parameter, ' +
                'please use this parameter consistently with all subcommands. ' +
                '(Default: 0.05). ' +
                "Default: ${params.semibin2_ratio}",
            cliflag: '--ratio',
            clivalue: (params.semibin2_ratio ?: '')
        ],
        'semibin2_verbose': [
            clihelp: 'Verbose output. ' +
                "Default: ${params.semibin2_verbose}",
            cliflag: '--verbose',
            clivalue: (params.semibin2_verbose ? ' ' : '')
        ],
        'semibin2_quiet': [
            clihelp: 'Quiet output. ' +
                "Default: ${params.semibin2_quiet}",
            cliflag: '-q',
            clivalue: (params.semibin2_quiet ? ' ' : '')
        ],
        'semibin2_reference_db': [
            clihelp: 'GTDB reference storage path. (Default: $HOME/.cache/SemiBin/mmseqs2-GTDB). ' +
                'If not set --reference-db and SemiBin cannot find GTDB in $HOME/.cache/SemiBin/mmseqs2-GTDB, ' +
                'SemiBin will download GTDB (Note that >100GB of disk space are required). ' +
                "Default: ${params.semibin2_reference_db}",
            cliflag: '-r',
            clivalue: (params.semibin2_reference_db ? ' ' : '')
        ],
        'semibin2_reference_db_data_dir': [
            clihelp: 'GTDB reference storage path. (Default: $HOME/.cache/SemiBin/mmseqs2-GTDB). ' +
                'If not set --reference-db and SemiBin cannot find GTDB in $HOME/.cache/SemiBin/mmseqs2-GTDB, ' +
                'SemiBin will download GTDB (Note that >100GB of disk space are required). ' +
                "Default: ${params.semibin2_reference_db_data_dir}",
            cliflag: '--reference-db',
            clivalue: (params.semibin2_reference_db_data_dir ? ' ' : '')
        ],
        'semibin2_cannot_name': [
            clihelp: 'Name for the cannot-link file (default: cannot). ' +
                "Default: ${params.semibin2_cannot_name}",
            cliflag: '--cannot-name',
            clivalue: (params.semibin2_cannot_name ?: '')
        ],
        'semibin2_taxonomy_annotation_table': [
            clihelp: 'Pre-computed mmseqs2 format taxonomy TSV file to bypass mmseqs2 GTDB annotation [advanced]. ' +
                'When running with multi-sample binning, please make sure that the order of the taxonomy TSV file ' +
                'and the contig file (used for the combined fasta) is same. ' +
                "Default: ${params.semibin2_taxonomy_annotation_table}",
            cliflag: '--taxonomy-annotation-table',
            clivalue: (params.semibin2_taxonomy_annotation_table ? ' ' : '')
        ],
        'semibin2_epochs': [
            clihelp: 'Number of epochs used in the training process (Default: 15). ' +
                "Default: ${params.semibin2_epochs}",
            cliflag: '--epochs',
            clivalue: (params.semibin2_epochs ?: '')
        ],
        'semibin2_batch_size': [
            clihelp: 'Batch size used in the training process (Default: 2048). ' +
                "Default: ${params.semibin2_batch_size}",
            cliflag: '--batch-size',
            clivalue: (params.semibin2_batch_size ?: '')
        ],
        'semibin2_minfasta_kbs': [
            clihelp: 'Minimum bin size in Kbps (Default: 200). ' +
                "Default: ${params.semibin2_minfasta_kbs}",
            cliflag: '--minfasta-kbs',
            clivalue: (params.semibin2_minfasta_kbs ?: '')
        ],
        'semibin2_separator': [
            clihelp: 'Used when multiple samples binning to separate sample name and contig name ' +
                '(Default is :). ' +
                "Default: ${params.semibin2_separator}",
            cliflag: '-s',
            clivalue: (params.semibin2_separator ? ' ' : '')
        ],
        'semibin2_random_seed': [
            clihelp: 'Random seed. Set it to a fixed value to reproduce results across runs. ' +
                'The default is that the seed is set by the system and . ' +
                "Default: ${params.semibin2_random_seed}",
            cliflag: '--random-seed',
            clivalue: (params.semibin2_random_seed ?: '')
        ],
        'semibin2_ml_threshold': [
            clihelp: 'Length threshold for generating must-link constraints. ' +
                '(By default, the threshold is calculated from the contig, and the default minimum value is 4,000 bp). ' +
                "Default: ${params.semibin2_ml_threshold}",
            cliflag: '--ml-threshold',
            clivalue: (params.semibin2_ml_threshold ?: '')
        ],
        'semibin2_engine': [
            clihelp: 'Device used to train the model ' +
                '(auto/gpu/cpu, auto means if SemiBin detects the gpu, SemiBin will use GPU). ' +
                "Default: ${params.semibin2_engine}",
            cliflag: '--engine',
            clivalue: (params.semibin2_engine ?: '')
        ],
        'semibin2_semi_supervised': [
            clihelp: 'Train the model with semi-supervised learning. ' +
                "Default: ${params.semibin2_semi_supervised}",
            cliflag: '--semi-supervised',
            clivalue: (params.semibin2_semi_supervised ? ' ' : '')
        ],
        'semibin2_self_supervised': [
            clihelp: 'Train the model with self-supervised learning. ' +
                "Default: ${params.semibin2_self_supervised}",
            cliflag: '--self-supervised',
            clivalue: (params.semibin2_self_supervised ? ' ' : '')
        ],
        'semibin2_sequencing_type': [
            clihelp: 'Sequencing type in [short_read/long_read], Default: short_read. ' +
                "Default: ${params.semibin2_sequencing_type}",
            cliflag: '--sequencing-type',
            clivalue: (params.semibin2_sequencing_type ?: '')
        ],
        'semibin2_max_edges': [
            clihelp: 'The maximum number of edges that can be connected to one contig (Default: 200). ' +
                "Default: ${params.semibin2_max_edges}",
            cliflag: '--max-edges',
            clivalue: (params.semibin2_max_edges ?: '')
        ],
        'semibin2_max_node': [
            clihelp: 'Fraction of contigs that considered to be binned (should be between 0 and 1; default: 1). ' +
                "Default: ${params.semibin2_max_node}",
            cliflag: '--max-node',
            clivalue: (params.semibin2_max_node ?: '')
        ],
        'semibin2_no_recluster': [
            clihelp: 'Do not recluster bins. ' +
                "Default: ${params.semibin2_no_recluster}",
            cliflag: '--no-recluster',
            clivalue: (params.semibin2_no_recluster ? ' ' : '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}