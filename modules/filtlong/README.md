# NextFlow DSL2 Module

```bash
FILTLONG
```

## Description

Run `FILTLONG` tool on input data. This module filters long reads (Nanopore or PacBio) based on quality and length, optionally using short reads for additional filtering criteria.

\
&nbsp;

### `input:`

___

Type: `tuple`

Takes in the following tuple of metadata (`meta`) and input files.

Ex:

```groovy
[ [id: 'sample1'], '/data/sample1/input.file' ]
```

\
&nbsp;

#### `meta`

Type: Groovy Map

A Groovy Map containing the metadata about the input file.

Ex:

```groovy
[ id: 'FAL00870' ]
```

\
&nbsp;

#### `input_files`

Type: `path`

NextFlow input type of `path` pointing to input files to be processed.

\
&nbsp;

#### `args`

Type: Groovy String

String of optional command-line arguments to be passed to the tool.

Ex:

```groovy
withName: 'FILTLONG' {
    ext.args = '--some-argument'
}
```

\
&nbsp;

### `output:`

___

Type: `tuple`

Outputs a tuple of metadata (`meta` from `input:`) and result files.

\
&nbsp;

#### `results`

Type: `path`

NextFlow output type of `path` pointing to the result files per sample (`id:`).

\
&nbsp;

#### `versions`

Type: `path`

NextFlow output type of `path` pointing to the `.yml` file storing software versions for this process.
