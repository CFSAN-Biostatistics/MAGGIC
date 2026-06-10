Clone or download the repository and call `cpipes`:

```bash
./cpipes --pipeline maggic [options]
```

Or pull and run directly with `Nextflow`:

```bash
nextflow pull CFSAN-Biostatistics/maggic
nextflow list
nextflow info CFSAN-Biostatistics/maggic
nextflow run CFSAN-Biostatistics/maggic --pipeline maggic --help
```

## Default Run

```bash
cd /data/scratch/$USER
mkdir nf-maggic
cd nf-maggic
./cpipes \
    --pipeline maggic \
    --input /path/to/illumina/fastq/dir \
    --output /path/to/output \
    -profile ahptainer \
    -resume
```

## Single-End Mode

```bash
./cpipes \
    --pipeline maggic \
    --input /path/to/illumina/fastq/dir \
    --output /path/to/output \
    --fq_single_end true \
    --fq_filename_delim_idx 4 \
    -profile ahptainer \
    -resume
```

## Input

The input is a folder containing compressed (`.gz`) FASTQ files. Sample grouping is automatic based on file names.

For example, with these files:

- KB-01_apple_L001_R1.fastq.gz
- KB-01_apple_L001_R2.fastq.gz
- KB-01_apple_L002_R1.fastq.gz
- KB-01_apple_L002_R2.fastq.gz
- KB-02_mango_L001_R1.fastq.gz
- KB-02_mango_L001_R2.fastq.gz
- KB-02_mango_L002_R1.fastq.gz
- KB-02_mango_L002_R2.fastq.gz

To create two sample groups (`apple` and `mango`), split by underscore and group by the first 2 words (`--fq_filename_delim_idx 2`).

All FASTQ files should have uniform naming patterns.

## Output Directory Structure

All outputs are stored in the `--output` path. The MultiQC report is at `maggic-multiqc/CPIPES-Report_multiqc_report.html`.

| Directory | Description |
|-----------|-------------|
| `fastp/` | Quality-filtered FASTQ and JSON reports |
| `megahit/` | Metagenome assemblies (FASTA contigs) |
| `minimap2/` | Alignment BAM files |
| `vamb/` | `VAMB` binning output |
| `semibin2/` | `SemiBin2` binning output |
| `metabat2/` | `MetaBat 2` binning output |
| `binette/` | Consensus refined bins and quality reports |
| `gtdbtk/` | Taxonomic classification results |
| `genomad/` | Virus and plasmid detection results |
| `amrfinderplus/` | AMR gene detection results |
| `coverm_genome/` | Abundance/coverage tables |
| `maggic_results/` | Aggregated results TSVs |
| `table_summary/` | Summary tables |
| `maggic-multiqc/` | **MultiQC** HTML report |
