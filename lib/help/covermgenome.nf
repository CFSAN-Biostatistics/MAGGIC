// Help text for coverm genome within CPIPES.

def covermgenomeHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'coverm_genome_dereplicate': [
            clihelp: 'Dereplicate genomes via ANI using Dashing for preclustering and FastANI for final calculation. ' +
                'Uses Galah method transparently. ' +
                "Default: ${params.coverm_genome_dereplicate ?: false}",
            cliflag: '--dereplicate',
            clivalue: (params.coverm_genome_dereplicate ? ' ' : '')
        ],
        'coverm_genome_fasta_extension': [
            clihelp: 'File extension of genomes in the directory. ' +
                "Default: ${params.coverm_genome_fasta_extension}",
            cliflag: '-x',
            clivalue: (params.coverm_genome_fasta_extension ?: '')
        ],
        'coverm_genome_min_completeness': [
            clihelp: 'Ignore genomes with less completeness than this percentage. ' +
                "Default: ${params.coverm_genome_min_completeness}",
            cliflag: '--min-completeness',
            clivalue: (params.coverm_genome_min_completeness ?: '')
        ],
        'coverm_genome_max_contamination': [
            clihelp: 'Ignore genomes with more contamination than this percentage. ' +
                "Default: ${params.coverm_genome_max_contamination}",
            cliflag: '--max-contamination',
            clivalue: (params.coverm_genome_max_contamination ?: '')
        ],
        'coverm_genome_dereplication_ani': [
            clihelp: 'Overall ANI level to dereplicate at with FastANI. ' +
                "Default: ${params.coverm_genome_dereplication_ani}",
            cliflag: '--dereplication-ani',
            clivalue: (params.coverm_genome_dereplication_ani ?: '')
        ],
        'coverm_genome_dereplication_aligned_fraction': [
            clihelp: 'Min aligned fraction of two genomes for clustering. ' +
                "Default: ${params.coverm_genome_dereplication_aligned_fraction}",
            cliflag: '--dereplication-aligned-fraction',
            clivalue: (params.coverm_genome_dereplication_aligned_fraction ?: '')
        ],
        'coverm_genome_dereplication_fragment_length': [
            clihelp: 'Length of fragment used in FastANI calculation. ' +
                "Default: ${params.coverm_genome_dereplication_fragment_length}",
            cliflag: '--dereplication-fragment-length',
            clivalue: (params.coverm_genome_dereplication_fragment_length ?: '')
        ],
        'coverm_genome_dereplication_quality_formula': [
            clihelp: 'Scoring function for genome quality. Options: Parks2020_reduced, ' +
                'completeness-4contamination, completeness-5contamination, dRep. ' +
                "Default: ${params.coverm_genome_dereplication_quality_formula}",
            cliflag: '--dereplication-quality-formula',
            clivalue: (params.coverm_genome_dereplication_quality_formula ?: '')
        ],
        'coverm_genome_dereplication_prethreshold_ani': [
            clihelp: 'Require at least this dashing-derived ANI for preclustering. ' +
                "Default: ${params.coverm_genome_dereplication_prethreshold_ani}",
            cliflag: '--dereplication-prethreshold-ani',
            clivalue: (params.coverm_genome_dereplication_prethreshold_ani ?: '')
        ],
        'coverm_genome_dereplication_precluster_method': [
            clihelp: 'Method for rough ANI calculation. Options: dashing, finch, skani. ' +
                "Default: ${params.coverm_genome_dereplication_precluster_method}",
            cliflag: '--dereplication-precluster-method',
            clivalue: (params.coverm_genome_dereplication_precluster_method ?: '')
        ],
        'coverm_genome_dereplication_cluster_method': [
            clihelp: 'Method for ANI calculation. Options: fastani, skani. ' +
                "Default: ${params.coverm_genome_dereplication_cluster_method}",
            cliflag: '--dereplication-cluster-method',
            clivalue: (params.coverm_genome_dereplication_cluster_method ?: '')
        ],
        'coverm_genome_dereplication_output_cluster_definition': [
            clihelp: 'Output a file of representative<TAB>member lines. ' +
                "Default: ${params.coverm_genome_dereplication_output_cluster_definition}",
            cliflag: '--dereplication-output-cluster-definition',
            clivalue: (params.coverm_genome_dereplication_output_cluster_definition ?: '')
        ],
        'coverm_genome_dereplication_output_rep_fa_dir': [
            clihelp: 'Symlink representative genomes into this directory. ' +
                "Default: ${params.coverm_genome_dereplication_output_rep_fa_dir}",
            cliflag: '--dereplication-output-representative-fasta-directory',
            clivalue: (params.coverm_genome_dereplication_output_rep_fa_dir ?: '')
        ],
        'coverm_genome_dereplication_output_rep_fa_dir_copy': [
            clihelp: 'Copy representative genomes into this directory. ' +
                "Default: ${params.coverm_genome_dereplication_output_rep_fa_dir_copy}",
            cliflag: '--dereplication-output-representative-fasta-directory-copy',
            clivalue: (params.coverm_genome_dereplication_output_rep_fa_dir_copy ?: '')
        ],
        'coverm_genome_dereplication_output_rep_list': [
            clihelp: 'Print newline separated list of paths to representatives into this file. ' +
                "Default: ${params.coverm_genome_dereplication_output_rep_list}",
            cliflag: '--dereplication-output-representative-list',
            clivalue: (params.coverm_genome_dereplication_output_rep_list ?: '')
        ],
        'coverm_genome_sharded': [
            clihelp: 'Choose best hit for each read pair when mapping to multiple reference contig sets. ' +
                "Default: ${params.coverm_genome_sharded}",
            cliflag: '--sharded',
            clivalue: (params.coverm_genome_sharded ? ' ' : '')
        ],
        'coverm_genome_exclude_genomes_from_deshard': [
            clihelp: 'Ignore genomes whose name appears in this newline-separated file when combining shards. ' +
                "Default: ${params.coverm_genome_exclude_genomes_from_deshard}",
            cliflag: '--exclude-genomes-from-deshard',
            clivalue: (params.coverm_genome_exclude_genomes_from_deshard ?: '')
        ],
        'coverm_genome_mapper': [
            clihelp: 'Underlying mapping software. Options: minimap2-sr, bwa-mem, ' +
                'bwa-mem2, minimap2-ont, minimap2-pb, minimap2-hifi, minimap2-no-preset. ' +
                "Default: ${params.coverm_genome_mapper}",
            cliflag: '-p',
            clivalue: (params.coverm_genome_mapper ?: 'minimap2-sr')
        ],
        'coverm_genome_minimap2_params': [
            clihelp: 'Extra parameters for minimap2 indexing and mapping commands. ' +
                "Default: ${params.coverm_genome_minimap2_params}",
            cliflag: '--minimap2-params',
            clivalue: (params.coverm_genome_minimap2_params ?: '')
        ],
        'coverm_genome_minimap2_reference_is_index': [
            clihelp: 'Treat reference as a minimap2 database, not as a FASTA file. ' +
                "Default: ${params.coverm_genome_minimap2_reference_is_index}",
            cliflag: '--minimap2-reference-is-index',
            clivalue: (params.coverm_genome_minimap2_reference_is_index ? ' ' : '')
        ],
        'coverm_genome_bwa_params': [
            clihelp: 'Extra parameters for BWA or BWA-MEM2. ' +
                "Default: ${params.coverm_genome_bwa_params}",
            cliflag: '--bwa-params',
            clivalue: (params.coverm_genome_bwa_params ?: '')
        ],
        'coverm_genome_strobealign_params': [
            clihelp: 'Extra parameters for strobealign. ' +
                "Default: ${params.coverm_genome_strobealign_params}",
            cliflag: '--strobealign-params',
            clivalue: (params.coverm_genome_strobealign_params ?: '')
        ],
        'coverm_genome_min_read_aligned_length': [
            clihelp: 'Exclude reads with smaller numbers of aligned bases. ' +
                "Default: ${params.coverm_genome_min_read_aligned_length}",
            cliflag: '--min-read-aligned-length',
            clivalue: (params.coverm_genome_min_read_aligned_length ?: '')
        ],
        'coverm_genome_min_read_percent_identity': [
            clihelp: 'Exclude reads by overall percent identity e.g. 95 for 95%. ' +
                "Default: ${params.coverm_genome_min_read_percent_identity}",
            cliflag: '--min-read-percent-identity',
            clivalue: (params.coverm_genome_min_read_percent_identity ?: '')
        ],
        'coverm_genome_min_read_aligned_percent': [
            clihelp: 'Exclude reads by percent aligned bases e.g. 95 means 95% of bases must be aligned. ' +
                "Default: ${params.coverm_genome_min_read_aligned_percent}",
            cliflag: '--min-read-aligned-percent',
            clivalue: (params.coverm_genome_min_read_aligned_percent ?: '')
        ],
        'coverm_genome_min_read_aligned_length_pair': [
            clihelp: 'Exclude pairs with smaller numbers of aligned bases. Implies --proper-pairs-only. ' +
                "Default: ${params.coverm_genome_min_read_aligned_length_pair}",
            cliflag: '--min-read-aligned-length-pair',
            clivalue: (params.coverm_genome_min_read_aligned_length_pair ?: '')
        ],
        'coverm_genome_min_read_percent_identity_pair': [
            clihelp: 'Exclude pairs by overall percent identity. Implies --proper-pairs-only. ' +
                "Default: ${params.coverm_genome_min_read_percent_identity_pair}",
            cliflag: '--min-read-percent-identity-pair',
            clivalue: (params.coverm_genome_min_read_percent_identity_pair ?: '')
        ],
        'coverm_genome_min_read_aligned_percent_pair': [
            clihelp: 'Exclude pairs by percent aligned bases. Implies --proper-pairs-only. ' +
                "Default: ${params.coverm_genome_min_read_aligned_percent_pair}",
            cliflag: '--min-read-aligned-percent-pair',
            clivalue: (params.coverm_genome_min_read_aligned_percent_pair ?: '')
        ],
        'coverm_genome_proper_pairs_only': [
            clihelp: 'Require reads to be mapped as proper pairs. ' +
                "Default: ${params.coverm_genome_proper_pairs_only}",
            cliflag: '--proper-pairs-only',
            clivalue: (params.coverm_genome_proper_pairs_only ? ' ' : '')
        ],
        'coverm_genome_exclude_supplementary': [
            clihelp: 'Exclude supplementary alignments. ' +
                "Default: ${params.coverm_genome_exclude_supplementary}",
            cliflag: '--exclude-supplementary',
            clivalue: (params.coverm_genome_exclude_supplementary ? ' ' : '')
        ],
        'coverm_genome_include_secondary': [
            clihelp: 'Include secondary alignments. ' +
                "Default: ${params.coverm_genome_include_secondary}",
            cliflag: '--include-secondary',
            clivalue: (params.coverm_genome_include_secondary ? ' ' : '')
        ],
        'coverm_genome_methods': [
            clihelp: 'Method(s) for calculating coverage. Options: relative_abundance, mean, ' +
                'trimmed_mean, coverage_histogram, covered_bases, variance, length, count, reads_per_base, rpkm, tpm. ' +
                "Default: ${params.coverm_genome_methods}",
            cliflag: '-m',
            clivalue: (params.coverm_genome_methods ?: 'relative_abundance')
        ],
        'coverm_genome_min_covered_fraction': [
            clihelp: 'Genomes with less covered bases than this are reported as having zero coverage. ' +
                "Default: ${params.coverm_genome_min_covered_fraction}",
            cliflag: '--min-covered-fraction',
            clivalue: (params.coverm_genome_min_covered_fraction ?: '10')
        ],
        'coverm_genome_contig_end_exclusion': [
            clihelp: 'Exclude bases at the ends of reference sequences from calculation. ' +
                "Default: ${params.coverm_genome_contig_end_exclusion}",
            cliflag: '--contig-end-exclusion',
            clivalue: (params.coverm_genome_contig_end_exclusion ?: '75')
        ],
        'coverm_genome_trim_min': [
            clihelp: 'Remove this smallest fraction of positions when calculating trimmed_mean. ' +
                "Default: ${params.coverm_genome_trim_min}",
            cliflag: '--trim-min',
            clivalue: (params.coverm_genome_trim_min ?: '5')
        ],
        'coverm_genome_trim_max': [
            clihelp: 'Maximum fraction for trimmed_mean calculations. ' +
                "Default: ${params.coverm_genome_trim_max}",
            cliflag: '--trim-max',
            clivalue: (params.coverm_genome_trim_max ?: '95')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}