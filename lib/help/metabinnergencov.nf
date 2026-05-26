// Help text for metabinner gen_coverage_file within CPIPES.

def metabinnergencovHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'metabinner_gencov_assembly_file': [
            clihelp: 'Metagenomic assembly file. ' +
                "Default: ${params.metabinner_gencov_assembly_file}",
            cliflag: '-a',
            clivalue: (params.metabinner_gencov_assembly_file ?: '')
        ],
        'metabinner_gencov_output_dir': [
            clihelp: 'Output directory (to save the coverage files). ' +
                "Default: ${params.metabinner_gencov_output_dir}",
            cliflag: '-o',
            clivalue: (params.metabinner_gencov_output_dir ?: '')
        ],
        'metabinner_gencov_bam_dir': [
            clihelp: 'Directory for the bam files. ' +
                "Default: ${params.metabinner_gencov_bam_dir}",
            cliflag: '-b',
            clivalue: (params.metabinner_gencov_bam_dir ?: '')
        ],
        'metabinner_gencov_threads': [
            clihelp: 'Number of threads (default=1). ' +
                "Default: ${params.metabinner_gencov_threads}",
            cliflag: '-t',
            clivalue: (params.metabinner_gencov_threads ?: '')
        ],
        'metabinner_gencov_ram': [
            clihelp: 'Amount of RAM available (default=4). ' +
                "Default: ${params.metabinner_gencov_ram}",
            cliflag: '-m',
            clivalue: (params.metabinner_gencov_ram ?: '')
        ],
        'metabinner_gencov_min_contig_length': [
            clihelp: 'Minimum contig length to bin (default=1000bp). ' +
                "Default: ${params.metabinner_gencov_min_contig_length}",
            cliflag: '-l',
            clivalue: (params.metabinner_gencov_min_contig_length ?: '')
        ],
        'metabinner_gencov_single_end': [
            clihelp: 'Non-paired reads mode (provide *.fastq files). ' +
                "Default: ${params.metabinner_gencov_single_end}",
            cliflag: '--single-end',
            clivalue: (params.metabinner_gencov_single_end ? ' ' : '')
        ],
        'metabinner_gencov_interleaved': [
            clihelp: 'The input read files contain interleaved paired-end reads. ' +
                "Default: ${params.metabinner_gencov_interleaved}",
            cliflag: '--interleaved',
            clivalue: (params.metabinner_gencov_interleaved ? ' ' : '')
        ],
        'metabinner_gencov_forward_suffix': [
            clihelp: 'Forward read suffix for paired reads (default=_1.fastq). ' +
                "Default: ${params.metabinner_gencov_forward_suffix}",
            cliflag: '-f',
            clivalue: (params.metabinner_gencov_forward_suffix ?: '')
        ],
        'metabinner_gencov_reverse_suffix': [
            clihelp: 'Reverse read suffix for paired reads (default=_2.fastq). ' +
                "Default: ${params.metabinner_gencov_reverse_suffix}",
            cliflag: '-r',
            clivalue: (params.metabinner_gencov_reverse_suffix ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}