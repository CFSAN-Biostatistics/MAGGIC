// Help text for drep dereplicate within CPIPES.

def drepdereplicateHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'drepdereplicate_cpus': [
            clihelp: 'Threads (default=6). ' +
                "Default: ${params.drepdereplicate_cpus}",
            cliflag: '-p',
            clivalue: (params.drepdereplicate_cpus ?: 6)
        ],
        'drepdereplicate_debug': [
            clihelp: 'Make extra debugging output (default=False). ' +
                "Default: ${params.drepdereplicate_debug}",
            cliflag: '-d',
            clivalue: (params.drepdereplicate_debug ? ' ' : '')
        ],
        'drepdereplicate_genomes': [
            clihelp: 'Genomes to filter in .fasta format. Not necessary if Bdb or Wdb already exist. ' +
                'Can also input a text file with paths to genomes, which results in fewer OS issues than ' +
                'wildcard expansion (default=None). ' +
                "Default: ${params.drepdereplicate_genomes}",
            cliflag: '-g',
            clivalue: (params.drepdereplicate_genomes ?: '')
        ],
        'drepdereplicate_length': [
            clihelp: 'Minimum genome length (default=50000). ' +
                "Default: ${params.drepdereplicate_length}",
            cliflag: '-l',
            clivalue: (params.drepdereplicate_length ?: 50000)
        ],
        'drepdereplicate_completeness': [
            clihelp: 'Minimum genome completeness (default=75). ' +
                "Default: ${params.drepdereplicate_completeness}",
            cliflag: '-comp',
            clivalue: (params.drepdereplicate_completeness ?: '')
        ],
        'drepdereplicate_contamination': [
            clihelp: 'Maximum genome contamination (default=25). ' +
                "Default: ${params.drepdereplicate_contamination}",
            cliflag: '-con',
            clivalue: (params.drepdereplicate_contamination ?: '')
        ],
        'drepdereplicate_ignoreGenomeQuality': [
            clihelp: 'Don\'t run checkM or do any quality filtering. NOT RECOMMENDED! This is useful for use ' +
                'with bacteriophages or eukaryotes or things where checkM scoring does not work. ' +
                'Will only choose genomes based on length and N50 (default=False). ' +
                "Default: ${params.drepdereplicate_ignoreGenomeQuality}",
            cliflag: '--ignoreGenomeQuality',
            clivalue: (params.drepdereplicate_ignoreGenomeQuality ?: '')
        ],
        'drepdereplicate_genomeInfo': [
            clihelp: 'location of .csv file containing quality information on the genomes. ' +
                'Must contain: ["genome"(basename of .fasta file of that genome), "completeness"(0-100 value for completeness of the genome), ' +
                '"contamination"(0-100 value of the contamination of the genome)] (default=None). ' +
                "Default: ${params.drepdereplicate_genomeInfo}",
            cliflag: '--genomeInfo',
            clivalue: (params.drepdereplicate_genomeInfo ?: '')
        ],
        'drepdereplicate_checkM_method': [
            clihelp: 'Either lineage_wf (more accurate) or taxonomy_wf (faster) (default=lineage_wf). ' +
                "Default: ${params.drepdereplicate_checkM_method}",
            cliflag: '--checkM_method',
            clivalue: (params.drepdereplicate_checkM_method ?: '')
        ],
        'drepdereplicate_set_recursion': [
            clihelp: 'Increases the python recursion limit. NOT RECOMMENDED unless checkM is crashing due to ' +
                'recursion issues. Recommended to set to 2000 if needed, but setting this could crash python (default=0). ' +
                "Default: ${params.drepdereplicate_set_recursion}",
            cliflag: '--set_recursion',
            clivalue: (params.drepdereplicate_set_recursion ?: '')
        ],
        'drepdereplicate_checkm_group_size': [
            clihelp: 'The number of genomes passed to checkM at a time. Increasing this increases RAM but makes checkM faster (default=2000). ' +
                "Default: ${params.drepdereplicate_checkm_group_size}",
            cliflag: '--checkm_group_size',
            clivalue: (params.drepdereplicate_checkm_group_size ?: '')
        ],
        'drepdereplicate_S_algorithm': [
            clihelp: 'Algorithm for secondary clustering comparisons (default=fastANI). ' +
                'fastANI = Kmer-based approach; very fast. ' +
                'skani = Even faster Kmer-based approach. ' +
                'ANImf = (DEFAULT) Align whole genomes with nucmer; filter alignment; compare aligned regions. ' +
                'ANIn = Align whole genomes with nucmer; compare aligned regions. ' +
                'gANI = Identify and align ORFs; compare aligned ORFS. ' +
                'goANI = Open source version of gANI; requires nsmimscan. ' +
                "Default: ${params.drepdereplicate_S_algorithm}",
            cliflag: '--S_algorithm',
            clivalue: (params.drepdereplicate_S_algorithm ?: '')
        ],
        'drepdereplicate_MASH_sketch': [
            clihelp: 'MASH sketch size (default=1000). ' +
                "Default: ${params.drepdereplicate_MASH_sketch}",
            cliflag: '-ms',
            clivalue: (params.drepdereplicate_MASH_sketch ?: '')
        ],
        'drepdereplicate_SkipMash': [
            clihelp: 'Skip MASH clustering, just do secondary clustering on all genomes (default=False). ' +
                "Default: ${params.drepdereplicate_SkipMash}",
            cliflag: '--SkipMash',
            clivalue: (params.drepdereplicate_SkipMash ?: '')
        ],
        'drepdereplicate_SkipSecondary': [
            clihelp: 'Skip secondary clustering, just perform MASH clustering (default=False). ' +
                "Default: ${params.drepdereplicate_SkipSecondary}",
            cliflag: '--SkipSecondary',
            clivalue: (params.drepdereplicate_SkipSecondary ?: '')
        ],
        'drepdereplicate_skani_extra': [
            clihelp: 'Extra arguments to pass to skani triangle (default=). ' +
                "Default: ${params.drepdereplicate_skani_extra}",
            cliflag: '--skani_extra',
            clivalue: (params.drepdereplicate_skani_extra ?: '')
        ],
        'drepdereplicate_n_PRESET': [
            clihelp: 'Presets to pass to nucmer (default=normal). ' +
                'tight = only align highly conserved regions. ' +
                'normal = default ANIn parameters. ' +
                "Default: ${params.drepdereplicate_n_PRESET}",
            cliflag: '--n_PRESET',
            clivalue: (params.drepdereplicate_n_PRESET ?: '')
        ],
        'drepdereplicate_P_ani': [
            clihelp: 'ANI threshold to form primary (MASH) clusters (default=0.9). ' +
                "Default: ${params.drepdereplicate_P_ani}",
            cliflag: '-pa',
            clivalue: (params.drepdereplicate_P_ani ?: '')
        ],
        'drepdereplicate_S_ani': [
            clihelp: 'ANI threshold to form secondary clusters (default=0.95). ' +
                "Default: ${params.drepdereplicate_S_ani}",
            cliflag: '-sa',
            clivalue: (params.drepdereplicate_S_ani ?: '')
        ],
        'drepdereplicate_cov_thresh': [
            clihelp: 'Minmum level of overlap between genomes when doing secondary comparisons (default=0.1). ' +
                "Default: ${params.drepdereplicate_cov_thresh}",
            cliflag: '-nc',
            clivalue: (params.drepdereplicate_cov_thresh ?: '')
        ],
        'drepdereplicate_coverage_method': [
            clihelp: 'Method to calculate coverage of an alignment (default=larger). ' +
                'total = 2*(aligned length) / (sum of total genome lengths). ' +
                'larger = max((aligned length / genome 1), (aligned_length / genome2)). ' +
                "Default: ${params.drepdereplicate_coverage_method}",
            cliflag: '-cm',
            clivalue: (params.drepdereplicate_coverage_method ?: '')
        ],
        'drepdereplicate_clusterAlg': [
            clihelp: 'Algorithm used to cluster genomes (default=average). ' +
                "Default: ${params.drepdereplicate_clusterAlg}",
            cliflag: '--clusterAlg',
            clivalue: (params.drepdereplicate_clusterAlg ?: '')
        ],
        'drepdereplicate_low_ram_primary_clustering': [
            clihelp: 'Use a memory-efficient algorithm for primary clustering. This only affects primary clustering ' +
                'and not secondary clustering. (default=False). ' +
                "Default: ${params.drepdereplicate_low_ram_primary_clustering}",
            cliflag: '--low_ram_primary_clustering',
            clivalue: (params.drepdereplicate_low_ram_primary_clustering ?: '')
        ],
        'drepdereplicate_multiround_primary_clustering': [
            clihelp: 'Cluster each primary clunk separately and merge at the end with single linkage. ' +
                'Decreases RAM usage and increases speed, and the cost of a minor loss in precision and the ' +
                'inability to plot primary_clustering_dendrograms. Especially helpful when clustering 5000+ genomes. ' +
                'Will be done with single linkage clustering (default=False). ' +
                "Default: ${params.drepdereplicate_multiround_primary_clustering}",
            cliflag: '--multiround_primary_clustering',
            clivalue: (params.drepdereplicate_multiround_primary_clustering ?: '')
        ],
        'drepdereplicate_primary_chunksize': [
            clihelp: 'Impacts multiround_primary_clustering. If you have more than this many genomes, process them ' +
                'in chunks of this size. (default=5000). ' +
                "Default: ${params.drepdereplicate_primary_chunksize}",
            cliflag: '--primary_chunksize',
            clivalue: (params.drepdereplicate_primary_chunksize ?: '')
        ],
        'drepdereplicate_greedy_secondary_clustering': [
            clihelp: 'Use a heuristic to avoid pair-wise comparisons when doing secondary clustering. ' +
                'Will be done with single linkage clustering. Only works for fastANI S_algorithm option at the moment (default=False). ' +
                "Default: ${params.drepdereplicate_greedy_secondary_clustering}",
            cliflag: '--greedy_secondary_clustering',
            clivalue: (params.drepdereplicate_greedy_secondary_clustering ?: '')
        ],
        'drepdereplicate_run_tertiary_clustering': [
            clihelp: 'Run an additional round of clustering on the final genome set. This is especially useful when ' +
                'greedy clustering is performed and/or to handle cases where similar genomes end up in different ' +
                'primary clusters. Only works with dereplicate, not compare. (default=False). ' +
                "Default: ${params.drepdereplicate_run_tertiary_clustering}",
            cliflag: '--run_tertiary_clustering',
            clivalue: (params.drepdereplicate_run_tertiary_clustering ?: '')
        ],
        'drepdereplicate_completeness_weight': [
            clihelp: 'completeness weight (default=1). ' +
                "Default: ${params.drepdereplicate_completeness_weight}",
            cliflag: '-comW',
            clivalue: (params.drepdereplicate_completeness_weight ?: '')
        ],
        'drepdereplicate_contamination_weight': [
            clihelp: 'contamination weight (default=5). ' +
                "Default: ${params.drepdereplicate_contamination_weight}",
            cliflag: '-conW',
            clivalue: (params.drepdereplicate_contamination_weight ?: '')
        ],
        'drepdereplicate_strain_heterogeneity_weight': [
            clihelp: 'strain heterogeneity weight (default=1). ' +
                "Default: ${params.drepdereplicate_strain_heterogeneity_weight}",
            cliflag: '-strW',
            clivalue: (params.drepdereplicate_strain_heterogeneity_weight ?: '')
        ],
        'drepdereplicate_N50_weight': [
            clihelp: 'weight of log(genome N50) (default=0.5). ' +
                "Default: ${params.drepdereplicate_N50_weight}",
            cliflag: '-N50W',
            clivalue: (params.drepdereplicate_N50_weight ?: '')
        ],
        'drepdereplicate_size_weight': [
            clihelp: 'weight of log(genome size) (default=0). ' +
                "Default: ${params.drepdereplicate_size_weight}",
            cliflag: '-sizeW',
            clivalue: (params.drepdereplicate_size_weight ?: '')
        ],
        'drepdereplicate_centrality_weight': [
            clihelp: 'Weight of (centrality - S_ani) (default=1). ' +
                "Default: ${params.drepdereplicate_centrality_weight}",
            cliflag: '-centW',
            clivalue: (params.drepdereplicate_centrality_weight ?: '')
        ],
        'drepdereplicate_extra_weight_table': [
            clihelp: 'Path to a tab-separated file with two-columns, no headers, listing genome and extra score ' +
                'to apply to that genome (default=None). ' +
                "Default: ${params.drepdereplicate_extra_weight_table}",
            cliflag: '-extraW',
            clivalue: (params.drepdereplicate_extra_weight_table ?: '')
        ],
        'drepdereplicate_gen_warnings': [
            clihelp: 'Generate warnings (default=False). ' +
                "Default: ${params.drepdereplicate_gen_warnings}",
            cliflag: '--gen_warnings',
            clivalue: (params.drepdereplicate_gen_warnings ?: '')
        ],
        'drepdereplicate_warn_dist': [
            clihelp: 'How far from the threshold to throw cluster warnings (default=0.25). ' +
                "Default: ${params.drepdereplicate_warn_dist}",
            cliflag: '--warn_dist',
            clivalue: (params.drepdereplicate_warn_dist ?: '')
        ],
        'drepdereplicate_warn_sim': [
            clihelp: 'Similarity threshold for warnings between dereplicated genomes (default=0.98). ' +
                "Default: ${params.drepdereplicate_warn_sim}",
            cliflag: '--warn_sim',
            clivalue: (params.drepdereplicate_warn_sim ?: '')
        ],
        'drepdereplicate_warn_aln': [
            clihelp: 'Minimum aligned fraction for warnings between dereplicated genomes (ANIn) (default=0.25). ' +
                "Default: ${params.drepdereplicate_warn_aln}",
            cliflag: '--warn_aln',
            clivalue: (params.drepdereplicate_warn_aln ?: '')
        ],
        'drepdereplicate_skip_plots': [
            clihelp: 'Dont make plots (default=False). ' +
                "Default: ${params.drepdereplicate_skip_plots}",
            cliflag: '--skip_plots',
            clivalue: (params.drepdereplicate_skip_plots ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}