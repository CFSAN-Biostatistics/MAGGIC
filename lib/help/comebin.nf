// Help text for comebin within CPIPES.

def comebinHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'comebin_run': [
            clihelp: 'Run comebin tool. Default: ' +
                (params.comebin_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'comebin_contig_file': [
            clihelp: 'Metagenomic assembly file. ' +
                "Default: ${params.comebin_contig_file}",
            cliflag: '-a',
            clivalue: (params.comebin_contig_file ?: '')
        ],
        'comebin_output_dir': [
            clihelp: 'Output directory. ' +
                "Default: ${params.comebin_output_dir}",
            cliflag: '-o',
            clivalue: (params.comebin_output_dir ?: '')
        ],
        'comebin_bam_file': [
            clihelp: 'Path to access to the bam files. ' +
                "Default: ${params.comebin_bam_file}",
            cliflag: '-p',
            clivalue: (params.comebin_bam_file ?: '')
        ],
        'comebin_num_views': [
            clihelp: 'Number of views for contrastive multiple-view learning (default=6). ' +
                "Default: ${params.comebin_num_views}",
            cliflag: '-n',
            clivalue: (params.comebin_num_views ?: '')
        ],
        'comebin_threads': [
            clihelp: 'Number of threads (default=5). ' +
                "Default: ${params.comebin_threads}",
            cliflag: '-t',
            clivalue: (params.comebin_threads ?: '')
        ],
        'comebin_temperature': [
            clihelp: 'Temperature in loss function (default=0.07 for assemblies with an N50 > 10000, ' +
                'default=0.15 for others). ' +
                "Default: ${params.comebin_temperature}",
            cliflag: '-l',
            clivalue: (params.comebin_temperature ?: '')
        ],
        'comebin_embedding_size': [
            clihelp: 'Embedding size for comebin network (default=2048). ' +
                "Default: ${params.comebin_embedding_size}",
            cliflag: '-e',
            clivalue: (params.comebin_embedding_size ?: '')
        ],
        'comebin_coverage_embedding': [
            clihelp: 'Embedding size for coverage network (default=2048). ' +
                "Default: ${params.comebin_coverage_embedding}",
            cliflag: '-c',
            clivalue: (params.comebin_coverage_embedding ?: '')
        ],
        'comebin_batch_size': [
            clihelp: 'Batch size for training process (default=1024). ' +
                "Default: ${params.comebin_batch_size}",
            cliflag: '-b',
            clivalue: (params.comebin_batch_size ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}