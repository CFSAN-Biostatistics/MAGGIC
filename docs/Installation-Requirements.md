## Minimum Requirements

1. **Nextflow version 25.10.5**
    - Make the `nextflow` binary executable (`chmod 755 nextflow`) and ensure it is available in your `$PATH`.
    - If your existing `JAVA` install does not support the newest Nextflow version, use Amazon's `JAVA` (OpenJDK): [Corretto](https://docs.aws.amazon.com/corretto/latest/corretto-21-ug/downloads-list.html).

2. **Container or package manager**: One of `micromamba`, `docker`, `singularity`, or `apptainer` installed and available in `$PATH`.
    - To install `micromamba`, follow these [installation steps](https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html#linux-and-macos).
    - Just the `curl` step is sufficient for running workflows.
    - After installation, upgrade to at least version `2.3.2`:

    ```bash
    micromamba --version
    micromamba self-update -c conda-forge
    ```

3. **Note**: Due to testing priority, only container (`apptainer`, `singularity`) based workflow has been fully validated. Please [report issues via GitHub](https://github.com/CFSAN-Biostatistics/MAGGIC/issues) if you encounter failures.

4. **Minimum hardware**: 20 CPU cores and 128 GB of memory for all workflow steps.

## Computational Resources

Most pipeline processes use the `process_low_turbo` resource label (20 CPUs, 128 GB memory per task). By default, MAGGIC uses 10 CPU cores where possible. Adjust with `--max_cpus`:

```bash
./cpipes \
    --pipeline maggic \
    --input /path/to/metagenomic_fastq/dir \
    --output /path/to/output \
    --max_cpus 5 \
    -profile ahptainer \
    -resume
```

## Runtime Profiles

Run the workflow on different compute environments by specifying a profile:

```bash
./cpipes \
    --pipeline maggic \
    --input /path/to/fastq_pass_dir \
    --output /path/to/where/output/should/go \
    -profile your_institution
```

Output goes to the `--output` path. Nextflow reports are stored in the working directory where `cpipes` is run.

### Adding a Custom Profile

Append to `conf/computeinfra.config`:

```groovy
your_institution {
    process.executor = 'sge'
    process.queue = 'normal.q'
    apptainer.enabled = false
    apptainer.autoMounts = true
    docker.enabled = false
    params.enable_conda = true
    conda.enabled = true
    conda.useMicromamba = true
    params.enable_module = false
}
```

By default, all software provisioning is disabled except `conda`. You can remove `process.queue` to let MAGGIC request resources automatically.

### Cloud Computing

Add runtime profiles for cloud environments. Example AWS Batch:

```groovy
my_aws_batch {
    executor = 'awsbatch'
    queue = 'my-batch-queue'
    aws.batch.cliPath = '/home/ec2-user/miniconda/bin/aws'
    aws.batch.region = 'us-east-1'
    apptainer.enabled = false
    apptainer.autoMounts = true
    docker.enabled = true
    params.conda_enabled = false
    params.enable_module = false
}
