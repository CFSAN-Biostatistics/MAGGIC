// Help text for vamb bin default within CPIPES.

def vambbindefHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'vambbindef_run': [
            clihelp: 'Run `vamb bin def` tool. Default: ' +
                (params.vambbindef_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'vambbindef_minlen': [
            clihelp: 'Ignore contigs shorter than this (default=2000). ' +
                "Default: ${params.vambbindef_minlen}",
            cliflag: '-m',
            clivalue: (params.vambbindef_minlen ?: '')
        ],
        'vambbindef_norefcheck': [
            clihelp: 'Skip reference name hashing check (default=False). ' +
                "Default: ${params.vambbindef_norefcheck}",
            cliflag: '--norefcheck',
            clivalue: (params.vambbindef_norefcheck ? ' ' : '')
        ],
        'vambbindef_seed': [
            clihelp: 'Random seed (determinism not guaranteed). ' +
                "Default: ${params.vambbindef_seed}",
            cliflag: '--seed',
            clivalue: (params.vambbindef_seed ?: '')
        ],
        'vambbindef_minfasta': [
            clihelp: 'Minimum bin size to output as fasta (default=None = no files). ' +
                "Default: ${params.vambbindef_minfasta}",
            cliflag: '--minfasta',
            clivalue: (params.vambbindef_minfasta ?: '')
        ],
        'vambbindef_binsplit_separator': [
            clihelp: 'Binsplit separator (default=C if present, pass empty string to disable). ' +
                "Default: ${params.vambbindef_binsplit_separator}",
            cliflag: '-o',
            clivalue: (params.vambbindef_binsplit_separator ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}