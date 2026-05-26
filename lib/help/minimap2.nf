// Help text for minimap2 within CPIPES.

def minimap2Help(params) {

    Map tool = [:]
    Map toolspecs = [:]
    tool.text = [:]
    tool.helpparams = [:]

    toolspecs = [
        'minimap2_run': [
            clihelp: 'Run minimap2 tool. Default: ' +
                (params.minimap2_run ?: false),
            cliflag: null,
            clivalue: null
        ],
        'minimap2_H': [
            clihelp: 'Use homopolymer-compressed k-mer (preferable for PacBio). ' +
                "Default: ${params.minimap2_H}",
            cliflag: '-H',
            clivalue: (params.minimap2_H ? ' ' : '')
        ],
        'minimap2_k': [
            clihelp: 'K-mer size (no larger than 28). ' +
                "Default: ${params.minimap2_k}",
            cliflag: '-k',
            clivalue: (params.minimap2_k ?: '')
        ],
        'minimap2_w': [
            clihelp: 'Minimizer window size. ' +
                "Default: ${params.minimap2_w}",
            cliflag: '-w',
            clivalue: (params.minimap2_w ?: '')
        ],
        'minimap2_I': [
            clihelp: 'Split index for every ~NUM input bases. ' +
                "Default: ${params.minimap2_I}",
            cliflag: '-I',
            clivalue: (params.minimap2_I ?: '')
        ],
        'minimap2_f': [
            clihelp: 'Filter out top FLOAT fraction of repetitive minimizers. ' +
                "Default: ${params.minimap2_f}",
            cliflag: '-f',
            clivalue: (params.minimap2_f ?: '')
        ],
        'minimap2_g': [
            clihelp: 'Stop chain elongation if there are no minimizers in INT-bp. ' +
                "Default: ${params.minimap2_g}",
            cliflag: '-g',
            clivalue: (params.minimap2_g ?: '')
        ],
        'minimap2_G': [
            clihelp: 'Max intron length (effective with -xsplice; changing -r). ' +
                "Default: ${params.minimap2_G}",
            cliflag: '-G',
            clivalue: (params.minimap2_G ?: '')
        ],
        'minimap2_F': [
            clihelp: 'Max fragment length (effective with -xsr or in the fragment mode). ' +
                "Default: ${params.minimap2_F}",
            cliflag: '-F',
            clivalue: (params.minimap2_F ?: '')
        ],
        'minimap2_r': [
            clihelp: 'Chaining/alignment bandwidth and long-join bandwidth. ' +
                "Default: ${params.minimap2_r}",
            cliflag: '-r',
            clivalue: (params.minimap2_r ?: '')
        ],
        'minimap2_n': [
            clihelp: 'Minimal number of minimizers on a chain. ' +
                "Default: ${params.minimap2_n}",
            cliflag: '-n',
            clivalue: (params.minimap2_n ?: '')
        ],
        'minimap2_m': [
            clihelp: 'Minimal chaining score (matching bases minus log gap penalty). ' +
                "Default: ${params.minimap2_m}",
            cliflag: '-m',
            clivalue: (params.minimap2_m ?: '')
        ],
        'minimap2_X': [
            clihelp: 'Skip self and dual mappings (for the all-vs-all mode). ' +
                "Default: ${params.minimap2_X}",
            cliflag: '-X',
            clivalue: (params.minimap2_X ? ' ' : '')
        ],
        'minimap2_p': [
            clihelp: 'Min secondary-to-primary score ratio. ' +
                "Default: ${params.minimap2_p}",
            cliflag: '-p',
            clivalue: (params.minimap2_p ?: '')
        ],
        'minimap2_N': [
            clihelp: 'Retain at most INT secondary alignments. ' +
                "Default: ${params.minimap2_N}",
            cliflag: '-N',
            clivalue: (params.minimap2_N ?: '')
        ],
        'minimap2_A': [
            clihelp: 'Matching score. ' +
                "Default: ${params.minimap2_A}",
            cliflag: '-A',
            clivalue: (params.minimap2_A ?: '')
        ],
        'minimap2_B': [
            clihelp: 'Mismatch penalty (larger value for lower divergence). ' +
                "Default: ${params.minimap2_B}",
            cliflag: '-B',
            clivalue: (params.minimap2_B ?: '')
        ],
        'minimap2_O': [
            clihelp: 'Gap open penalty. ' +
                "Default: ${params.minimap2_O}",
            cliflag: '-O',
            clivalue: (params.minimap2_O ?: '')
        ],
        'minimap2_E': [
            clihelp: 'Gap extension penalty; a k-long gap costs min{O1+k*E1,O2+k*E2}. ' +
                "Default: ${params.minimap2_E}",
            cliflag: '-E',
            clivalue: (params.minimap2_E ?: '')
        ],
        'minimap2_z': [
            clihelp: 'Z-drop score and inversion Z-drop score. ' +
                "Default: ${params.minimap2_z}",
            cliflag: '-z',
            clivalue: (params.minimap2_z ?: '')
        ],
        'minimap2_s': [
            clihelp: 'Minimal peak DP alignment score. ' +
                "Default: ${params.minimap2_s}",
            cliflag: '-s',
            clivalue: (params.minimap2_s ?: '')
        ],
        'minimap2_u': [
            clihelp: "How to find GT-AG. f:transcript strand, b:both strands, n:don't match GT-AG. " +
                "Default: ${params.minimap2_u}",
            cliflag: '-u',
            clivalue: (params.minimap2_u ?: '')
        ],
        'minimap2_J': [
            clihelp: 'Splice mode. 0: original minimap2 model; 1: miniprot model. ' +
                "Default: ${params.minimap2_J}",
            cliflag: '-J',
            clivalue: (params.minimap2_J ?: '')
        ],
        'minimap2_L': [
            clihelp: 'Write CIGAR with >65535 ops at the CG tag. ' +
                "Default: ${params.minimap2_L}",
            cliflag: '-L',
            clivalue: (params.minimap2_L ? ' ' : '')
        ],
        'minimap2_c': [
            clihelp: 'Output CIGAR in PAF. ' +
                "Default: ${params.minimap2_c}",
            cliflag: '-c',
            clivalue: (params.minimap2_c ? ' ' : '')
        ],
        'minimap2_cs': [
            clihelp: 'Output the cs tag; STR is short (if absent) or long. ' +
                "Default: ${params.minimap2_cs}",
            cliflag: '--cs',
            clivalue: (params.minimap2_cs ?: '')
        ],
        'minimap2_ds': [
            clihelp: 'Output the ds tag, which is an extension to cs. ' +
                "Default: ${params.minimap2_ds}",
            cliflag: '--ds',
            clivalue: (params.minimap2_ds ? ' ' : '')
        ],
        'minimap2_MD': [
            clihelp: 'Output the MD tag. ' +
                "Default: ${params.minimap2_MD}",
            cliflag: '--MD',
            clivalue: (params.minimap2_MD ? ' ' : '')
        ],
        'minimap2_eqx': [
            clihelp: 'Write =/X CIGAR operators. ' +
                "Default: ${params.minimap2_eqx}",
            cliflag: '--eqx',
            clivalue: (params.minimap2_eqx ? ' ' : '')
        ],
        'minimap2_Y': [
            clihelp: 'Use soft clipping for supplementary alignments. ' +
                "Default: ${params.minimap2_Y}",
            cliflag: '-Y',
            clivalue: (params.minimap2_Y ? ' ' : '')
        ],
        'minimap2_K': [
            clihelp: 'Minibatch size for mapping. ' +
                "Default: ${params.minimap2_K}",
            cliflag: '-K',
            clivalue: (params.minimap2_K ?: '')
        ],
        'minimap2_x': [
            clihelp: 'Alignment preset. ' +
                "Default: ${params.minimap2_x}",
            cliflag: '-x',
            clivalue: (params.minimap2_x ?: '')
        ]

    ]

    toolspecs.each {
        k, v -> tool.text['--' + k] = "${v.clihelp}"
        tool.helpparams[k] = [ cliflag: "${v.cliflag}", clivalue: v.clivalue ]
    }

    return tool
}