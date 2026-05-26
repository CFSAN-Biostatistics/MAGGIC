# maggic

`maggic` (**M**etagenomically **A**ssembled **G**enome **G**eneration with **I**ntegrated **C**lassification) is an automated workflow for the generation and refinement of Metagenome-Assembled Genomes (**MAGs**) from metagenomic sequencing data. It integrates multiple binning algorithms (**VAMB**, **SemiBin2**, **MetaBat 2**) followed by consensus-based bin refinement with **Binette**, taxonomic classification with **GTDB-Tk**, mobile genetic element detection with **geNomad**, and antimicrobial resistance gene profiling with **AMRFinderPlus**.

\
&nbsp;

<!-- TOC -->

- [Minimum Requirements](#minimum-requirements)
- [Database Requirements](#database-requirements)
- [Pipeline Overview](#pipeline-overview)
- [Multi-Sample Binning with Strata Control](#multi-sample-binning-with-strata-control)
- [Usage and Examples](#usage-and-examples)
  - [Input](#input)
  - [Output](#output)
  - [Computational resources](#computational-resources)
  - [Runtime profiles](#runtime-profiles)
  - [your_institution.config](#your_institutionconfig)
  - [Cloud computing](#cloud-computing)
- [maggic CLI Help](#maggic-cli-help)

<!-- /TOC -->

\
&nbsp;

## Minimum Requirements

1. [Nextflow version 25.10.5](https://github.com/nextflow-io/nextflow/releases/download/v25.10.5/nextflow).
    - Make the `nextflow` binary executable (`chmod 755 nextflow`) and also make sure that it is made available in your `$PATH`.
    - If your existing `JAVA` install does not support the newest **Nextflow** version, you can use **Amazon**'s `JAVA` (OpenJDK): [Corretto](https://docs.aws.amazon.com/corretto/latest/corretto-21-ug/downloads-list.html).
2. Either of `micromamba`, `docker`, `singularity`, or `apptainer` installed and available in your `$PATH`.
    - To install `micromamba` for your system type, please follow these [installation steps](https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html#linux-and-macos) and make sure that the `micromamba` binary is available in your `$PATH`.
    - Just the `curl` step is sufficient to download the binary as far as running the workflows are concerned.
    - Once you have finished the installation, **it is important that you upgrade `micromamba` to at least version `2.3.2` or greater**.

    ```bash
    micromamba --version
    micromamba self-update -c conda-forge
    ```

3. **Please Note**: Due to testing priority, only container (`apptainer`, `singularity`) based workflow has been fully validated. Please [report any issues via GitHub](https://github.com/CFSAN-Biostatistics/MAGGIC/issues) if you encounter any failures.
4. Minimum of 20 CPU cores and 128 GB of memory for all workflow steps.

\
&nbsp;

## Database Requirements

**The following databases are required before running the pipeline. All paths must be provided via command-line options or configuration files**:

- **GTDB-Tk reference database** (`--gtdbtk_classify_wf_data_path`): Used for taxonomic classification of **MAGs**.
- **CheckM2 database** (`--binette_checkm2_db`): Used by **Binette** for bin quality assessment.
- **geNomad database** (`--genomad_db`): Used for viral and plasmid element detection.
- **AMRFinderPlus database** (`--amrfinderplus_db`): Used for antimicrobial resistance gene profiling.
- For the sake of simplicity and ease of use, you can download all of them from [research.foodsafetyrisk.org](https://research.foodsafetyrisk.org/maggic/dbs/maggic_dbs.tar.bz2).
- Once you have downloaded the databases, uncompress the archive and set the UNIX paths in the configuration file as follows:
  - [Line 137](../workflows/conf/maggic.config#L137): `binette_checkm2_db = /path/to/maggic_dbs/checkm2/latest`
  - [Line 206](../workflows/conf/maggic.config#L206): `gtdbtk_classify_wf_data_path = /path/to/gtdbtk/release232`
  - [Line 216](../workflows/conf/maggic.config#L216): `genomad_db = /path/to/maggic_dbs/genomad/latest/genomad_db`
  - [Line 218](../workflows/conf/maggic.config#L218): `amrfinderplus_db = /path/to/maggic_dbs/amrfinderplus/latest`

**Setting the database paths in the configuration file is the recommended approach as it avoids having to specify them via CLI options on every pipeline run**.

\
&nbsp;

## Pipeline Overview

![MAGGIC Pipeline Overview](../assets/maggic_pipeline_diagram.svg)

\
&nbsp;

## Multi-Sample Binning with Strata Control

MAGGIC implements **strata-limited multi-sample binning**, a computationally efficient approach that dramatically improves **MAG** recovery while keeping alignment counts tractable for large cohorts.

Multi-sample binning works by aligning reads from multiple samples against every assembled contig set, providing binning tools (**VAMB**, **SemiBin2**, **MetaDecoder**) with rich cross-sample coverage profiles. As shown by <a href="https://doi.org/10.1038/s41467-025-57957-6" target="_blank">Han <em>et al</em>. 2025</a>, this approach recovers **41-43% more species and strains** compared to single-sample binning including rare taxa, near-complete strains, and antibiotic resistance gene hosts that single-sample binning misses entirely.

However, traditional all-vs-all alignment produces N² BAM files (50 samples = 2,500 alignments; 100 samples = 10,000 alignments and so on), which quickly becomes computationally intractable. Coverage diversity **saturates around 20-30 samples** for most metagenomic cohorts; beyond that, you gain marginal improvement at exponentially increasing computational cost (<a href="https://doi.org/10.1038/s41467-025-57957-6" target="_blank">Han <em>et al</em>. 2025</a>; <a href="https://doi.org/10.1038/s41587-020-00777-4" target="_blank">Nissen <em>et al</em>. 2021</a>; <a href="https://doi.org/10.3389/fmicb.2022.869135" target="_blank">Haryono <em>et al</em>. 2022</a>).

### How It Works

MAGGIC solves this with a strata-based approach controlled by two parameters:

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--multi_sample_strata` | `true` | Enable strata-limited mode (`true` by default. Set `false` for full all-vs-all) |
| `--strata_size` | `15` | Number of samples whose reads are aligned to each assembly |

Instead of aligning all N samples to all N assemblies (N² BAMs), MAGGIC selects `strata_size` samples and aligns their reads to every assembly, producing `strata_size × N` BAM files.

### Performance Comparison

| Samples | Full All-vs-All | Strata (15) | Reduction |
|---------|----------------|-------------|-----------|
| 30 | 900 BAMs | 450 BAMs | 2x |
| 50 | 2,500 BAMs | 750 BAMs | 3.3x |
| 100 | 10,000 BAMs | 1,500 BAMs | 6.7x |
| 200 | 40,000 BAMs | 3,000 BAMs | 13.3x |

The strata size of 15 is the default because it sits at the sweet spot: enough samples for robust cross-sample coverage profiles, yet small enough to keep compute times reasonable. For highly diverse cohorts (ex, environmental samples from disparate locations), you may want to increase `--strata_size` to 20-30. For homogeneous cohorts (ex, clinical samples from the same body site), 10-15 is sufficient.

```bash
./cpipes \
    --pipeline maggic \
    --input /path/to/fastq/dir \
    --output /path/to/output \
    --strata_size 20 \
    -profile singularity \
    -resume
```

\
&nbsp;

## Usage and Examples

Clone or download this repository and then call `cpipes`.

```bash
./cpipes --pipeline maggic [options]
```

Alternatively, you can use `nextflow` to directly pull and run the pipeline.

```bash
nextflow pull CFSAN-Biostatistics/maggic
nextflow list
nextflow info CFSAN-Biostatistics/maggic
nextflow run CFSAN-Biostatistics/maggic --pipeline maggic --help
```

\
&nbsp;

**Example**: Run the default `maggic` pipeline.

```bash
cd /data/scratch/$USER
mkdir nf-maggic
cd nf-maggic
./cpipes \
    --pipeline maggic \
    --input /path/to/illumina/fastq/dir \
    --output /path/to/output \
    -profile singularity \
    -resume
```

\
&nbsp;

**Example**: Run the `maggic` pipeline in single-end mode.

```bash
cd /data/scratch/$USER
mkdir nf-maggic
cd nf-maggic
./cpipes \
    --pipeline maggic \
    --input /path/to/illumina/fastq/dir \
    --output /path/to/output \
    --fq_single_end true \
    --fq_filename_delim_idx 4 \
    -profile singularity \
    -resume
```

\
&nbsp;

### Input

---

The input to the workflow is a folder containing compressed (`.gz`) FASTQ files. The sample grouping happens automatically by the file name of the FASTQ file. If, for example, a single sample is sequenced across multiple sequencing lanes, you can group those FASTQ files into one sample by using the `--fq_filename_delim` and `--fq_filename_delim_idx` options. By default, `--fq_filename_delim` is set to `_` (underscore) and `--fq_filename_delim_idx` is set to 1.

For example, if the directory contains FASTQ files as shown below:

- KB-01_apple_L001_R1.fastq.gz
- KB-01_apple_L001_R2.fastq.gz
- KB-01_apple_L002_R1.fastq.gz
- KB-01_apple_L002_R2.fastq.gz
- KB-02_mango_L001_R1.fastq.gz
- KB-02_mango_L001_R2.fastq.gz
- KB-02_mango_L002_R1.fastq.gz
- KB-02_mango_L002_R2.fastq.gz

Then, to create 2 sample groups, `apple` and `mango`, split the file name by the delimiter (underscore by default) and group by the first 2 words (`--fq_filename_delim_idx 2`).

All FASTQ files should have uniform naming patterns so that `--fq_filename_delim` and `--fq_filename_delim_idx` options do not have any adverse effect in collecting and creating a sample metadata sheet.

\
&nbsp;

### Output

---

All outputs for each step are stored inside the folder mentioned with the `--output` option. A `CPIPES-Report_multiqc_report.html` file inside the `maggic-multiqc` folder can be opened in any browser on your local workstation and contains a consolidated report.

**Output directory structure:**

| Directory | Description |
|-----------|-------------|
| `fastp/` | Quality filtered FASTQ files and JSON reports |
| `megahit/` | Metagenome assemblies (FASTA contigs) |
| `minimap2/` | Alignment BAM files |
| `vamb/` | **VAMB** binning output |
| `semibin2/` | **SemiBin2** binning output |
| `metabat2/` | **MetaBat 2** binning output |
| `binette/` | Consensus refined bins and quality reports |
| `gtdbtk/` | Taxonomic classification results |
| `genomad/` | Virus and plasmid detection results |
| `amrfinderplus/` | AMR gene detection results |
| `coverm_genome/` | Abundance/coverage tables |
| `maggic_results/` | Aggregated results TSV (`maggic-results.tsv`) |
| `table_summary/` | Summary tables |
| `maggic-multiqc/` | **MultiQC** HTML report |

\
&nbsp;

### Computational resources

---

Majority of the pipeline processes are configured with the `process_low_turbo` resource label, which requires a minimum of **20 CPU cores** and **128 GB of memory** per task. By default, `maggic` uses 10 CPU cores where possible. You can change this behavior and adjust the CPU cores with `--max_cpus` option.

\
&nbsp;

Example:

```bash
./cpipes \
    --pipeline maggic \
    --input /path/to/metagenomic_fastq/dir \
    --output /path/to/output \
    --max_cpus 5 \
    -profile singularity \
    -resume
```

\
&nbsp;

### Runtime profiles

---

You can use different runtime profiles that suit your specific compute environments i.e., you can run the workflow locally on your machine or in a grid computing infrastructure.

\
&nbsp;

Example:

```bash
cd /data/scratch/$USER
mkdir nf-maggic
cd nf-maggic
./cpipes \
    --pipeline maggic \
    --input /path/to/fastq_pass_dir \
    --output /path/to/where/output/should/go \
    -profile your_institution
```

The above command would run the pipeline and store the output at the location per the `--output` flag and the **Nextflow** reports are always stored in the current working directory from where `cpipes` is run. For example, for the above command, a directory called `CPIPES-maggic` would hold all the **Nextflow** related logs, reports and trace files.

\
&nbsp;

### `your_institution.config`

---

In the above example, we have mentioned the runtime profile as `your_institution`. For this to work, add the following lines at the end of [`computeinfra.config`](../conf/computeinfra.config) file which should be located inside the `conf` folder. For example, if your institution uses **SGE** or **UNIVA** for grid computing instead of **SLURM** and has a job queue named `normal.q`, then add these lines:

\
&nbsp;

```groovy
your_institution {
    process.executor = 'sge'
    process.queue = 'normal.q'
    singularity.enabled = false
    singularity.autoMounts = true
    docker.enabled = false
    params.enable_conda = true
    conda.enabled = true
    conda.useMicromamba = true
    params.enable_module = false
}
```

In the above example, by default, all the software provisioning choices are disabled except `conda`. You can also choose to remove the `process.queue` line altogether and the `maggic` workflow will request the appropriate memory and number of CPU cores automatically.

\
&nbsp;

### Cloud computing

---

You can run the workflow in the cloud (works only with proper set up of AWS resources). Add new runtime profiles with required parameters per [Nextflow docs](https://www.nextflow.io/docs/latest/executor.html):

\
&nbsp;

Example:

```groovy
my_aws_batch {
    executor = 'awsbatch'
    queue = 'my-batch-queue'
    aws.batch.cliPath = '/home/ec2-user/miniconda/bin/aws'
    aws.batch.region = 'us-east-1'
    singularity.enabled = false
    singularity.autoMounts = true
    docker.enabled = true
    params.conda_enabled = false
    params.enable_module = false
}
```

\
&nbsp;

## maggic CLI Help

```bash
[Kranti.Konganti@my-unix-box ]$ ./cpipes --pipeline maggic --help

N E X T F L O W   ~  version 25.10.5

Launching `./cpipes` [distracted_panini] DSL2 - revision: 0a03b0b454

====================================================================================================
             (o)
  ___  _ __   _  _ __    ___  ___
 / __|| '_ \ | || '_ \  / _ \/ __|
| (__ | |_) || || |_) ||  __/\__ \
 \___|| .__/ |_|| .__/  \___||___/
      | |       | |
      |_|       |_|
----------------------------------------------------------------------------------------------------
A collection of modular pipelines at CFSAN, FDA.
----------------------------------------------------------------------------------------------------
Name                                                   : CPIPES
Author                                                 : Kranti.Konganti@fda.hhs.gov
Version                                                : 0.9.0
Center                                                 : CFSAN, FDA.
====================================================================================================

----------------------------------------------------------------------------------------------------
Show configurable CLI options for each tool within maggic
----------------------------------------------------------------------------------------------------
Ex: cpipes --pipeline maggic --help
Ex: cpipes --pipeline maggic --help fastp
Ex: cpipes --pipeline maggic --help fastp,megahit
----------------------------------------------------------------------------------------------------
--help fastp                                           : Show fastp CLI options
--help megahit                                         : Show megahit CLI options
--help minimap2                                        : Show minimap2 CLI options
--help seb                                             : Show SemiBin2 `single_easy_bin` CLI options
--help vamb                                            : Show vamb `bin def` CLI options
--help binette                                         : Show binette CLI options
--help gtdbtk                                          : Show gtdbtk classify_wf CLI options
--help abundance                                       : Show coverm `genome` CLI options
--help amrfinderplus                                   : Show AMRFinderPlus CLI options
--help metabat2                                        : Show metabat2 CLI options
```
