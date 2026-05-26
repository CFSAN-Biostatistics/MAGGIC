// Help text for metabinner run_metabinner within CPIPES.

def metabinnerrunHelp(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'metabinner_run': [
            clihelp: 'Run metabinner tool. Default: ' +
                (params.metabinner_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'metabinner_run_dataset_scale': [
            clihelp: 'Dataset scale; eg. small,large,huge. ' +
                "Default: ${params.metabinner_run_dataset_scale}",
            cliflag: '-s',
            clivalue: (params.metabinner_run_dataset_scale ?: '')
        ]
    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}