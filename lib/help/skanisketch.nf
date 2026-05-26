// Help text for skani sketch within CPIPES.

def skanisketchHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'skanisketch_run': [
            clihelp: 'Run `skani sketch` tool. Default: ' +
                (params.skanisketch_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'skanisketch_i': [
            clihelp: "Use individual sequences instead the entire file for multi FASTA's. " +
                "Default: ${params.skanisketch_i}",
            cliflag: '-i',
            clivalue: (params.skanisketch_i ? ' ' : '')
        ],
        'skanisketch_c': [
            clihelp: 'Compression factor (k-mer subsampling rate). ' +
                "Default: ${params.skanisketch_c}",
            cliflag: '-c',
            clivalue: (params.skanisketch_c ?: '')
        ],
        'skanisketch_m': [
            clihelp: 'Marker k-mer compression factor. Markers are used for filtering. ' +
                'Consider decreasing to ~200-300 if working with small genomes ' + 
                '(e.g. plasmids or viruses). ' +
                "Default: ${params.skanisketch_m}",
            cliflag: '-m',
            clivalue: (params.skanisketch_m ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}