# NextFlow DSL2 Module

```bash
CAT_CAT
```

## Description

Concatenate multiple files into a single file with optional compression/decompression. This module can handle various combinations of input/output compression states and uses `cat` or `zcat` for reading and optionally `pigz` for compression.

\
&nbsp;

### `input:`

___

Type: `tuple`

Takes in the following tuple of metadata (`meta`) and a list of input files of input type `path` (`files_in`).

Ex:

```groovy
[ [id: 'sample1'], ['/data/sample1/file1.fq.gz', '/data/sample1/file2.fq.gz'] ]
```

\
&nbsp;

#### `meta`

Type: Groovy Map

A Groovy Map containing the metadata about the files.

Ex:

```groovy
[ id: 'FAL00870' ]
```

\
&nbsp;

#### `files_in`

Type: `path`

NextFlow input type of `path` pointing to input files to be concatenated.

\
&nbsp;

#### `args`

Type: Groovy String

String of optional command-line arguments to be passed to the concatenation command. This can be mentioned in `process` scope within `withName:process_name` block using `ext.args` option within your `nextflow.config` file.

Ex:

```groovy
withName: 'CAT_CAT' {
    ext.args = '--some-arg'
}
```

\
&nbsp;

#### `args2`

Type: Groovy String

String of optional command-line arguments to be passed to pigz compression command.

Ex:

```groovy
withName: 'CAT_CAT' {
    ext.args2 = '-6'  // compression level
}
```

\
&nbsp;

#### `prefix`

Type: Groovy String

Custom prefix for the output file. If not specified, uses the sample ID and extension from the first input file.

Ex:

```groovy
withName: 'CAT_CAT' {
    ext.prefix = 'custom_prefix'
}
```

\
&nbsp;

### `output:`

___

Type: `tuple`

Outputs a tuple of metadata (`meta` from `input:`) and the concatenated file.

\
&nbsp;

#### `concatenated_reads`

Type: `path`

NextFlow output type of `path` pointing to the concatenated file per sample (`id:`).

\
&nbsp;

#### `versions`

Type: `path`

NextFlow output type of `path` pointing to the `.yml` file storing software versions for this process.
