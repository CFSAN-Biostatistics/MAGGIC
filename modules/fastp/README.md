# NextFlow DSL2 Module

```bash
FASTP
```

## Description

Run `fastp` tool for fast all-in-one FASTQ preprocessor. Performs quality control, adapter trimming, quality filtering, and other preprocessing steps on FASTQ files.

\
&nbsp;

### `input:`

___

Type: `tuple`

Takes in the following tuple of metadata (`meta`) and reads of input type `path` (`reads`).

Ex:

```groovy
[ [id: 'sample1', single_end: true], '/data/sample1/reads.fastq.gz' ]
```

\
&nbsp;

#### `meta`

Type: Groovy Map

A Groovy Map containing the metadata about the FASTQ file.

Ex:

```groovy
[ id: 'FAL00870', single_end: true ]
```

\
&nbsp;

#### `reads`

Type: `path`

NextFlow input type of `path` pointing to FASTQ files to be processed.

\
&nbsp;

#### `args`

Type: Groovy String

String of optional command-line arguments to be passed to the tool. This can be mentioned in `process` scope within `withName:process_name` block using `ext.args` option within your `nextflow.config` file.

Ex:

```groovy
withName: 'FASTP' {
    ext.args = '--trim_poly_g --trim_poly_x'
}
```

\
&nbsp;

#### `prefix`

Type: Groovy String

Custom prefix for output files. If not specified, uses the sample ID.

Ex:

```groovy
withName: 'FASTP' {
    ext.prefix = 'custom_prefix'
}
```

\
&nbsp;

### `output:`

___

Type: `tuple`

Outputs multiple tuples with metadata (`meta` from `input:`) and various output files.

\
&nbsp;

#### `passed_reads`

Type: `path`

NextFlow output type of `path` pointing to the processed FASTQ file that passed quality control per sample (`id:`).

\
&nbsp;

#### `failed_reads`

Type: `path`

NextFlow output type of `path` pointing to the FASTQ file containing reads that failed quality control per sample (`id:`).

\
&nbsp;

#### `merged_reads`

Type: `path`

NextFlow output type of `path` pointing to the merged FASTQ file (for paired-end data) per sample (`id:`).

\
&nbsp;

#### `json`

Type: `path`

NextFlow output type of `path` pointing to the JSON report file containing quality control metrics per sample (`id:`).

\
&nbsp;

#### `html`

Type: `path`

NextFlow output type of `path` pointing to the HTML report file containing quality control metrics per sample (`id:`).

\
&nbsp;

#### `log`

Type: `path`

NextFlow output type of `path` pointing to the log file containing processing information per sample (`id:`).

\
&nbsp;

#### `versions`

Type: `path`

NextFlow output type of `path` pointing to the `.yml` file storing software versions for this process.
