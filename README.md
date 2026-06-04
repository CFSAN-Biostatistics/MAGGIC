# `maggic`

<p align="center">
  <img src="assets/maggic-icon.svg" alt="MAGGIC Logo" width="700" height="700"/>
</p>

`maggic` (**M**etagenomically **A**ssembled **G**enome **G**eneration with **I**ntegrated **C**lassification) is an automated workflow for the generation and refinement of Metagenome-Assembled Genomes (**MAGs**) from metagenomic sequencing data. It integrates multiple binning algorithms (**VAMB**, **SemiBin2**, **MetaBat 2**) followed by consensus-based bin refinement with **Binette**, taxonomic classification with **GTDB-Tk**, mobile genetic element detection with **geNomad**, and antimicrobial resistance gene profiling with **AMRFinderPlus**.

`maggic` works with **Illumina short-read** metagenomic sequencing data and produces quality-checked **MAGs** alongside comprehensive **MultiQC** reports.

It is written in **Nextflow** and is part of the modular data analysis pipelines (**CFSAN PIPELINES** or **CPIPES** for short) at **HFP**.

\
&nbsp;

## Software Information

* The current release version is **`v0.6.0`**.
* [See the full changelog](https://github.com/CFSAN-Biostatistics/maggic/releases).

\
&nbsp;

## Workflows

**CPIPES**:

 1. `maggic` : [READ Wiki](https://github.com/CFSAN-Biostatistics/MAGGIC/wiki).

\
&nbsp;

### Citing `maggic`

---

This is still a work in progress.

>
> **maggic: Metagenomically Assembled Genome Generation with Integrated Classification**
>
> Kranti Konganti. [*Work in Progress*].
>

\
&nbsp;

## Pipeline Overview

![MAGGIC Pipeline Overview](./assets/maggic_pipeline_diagram.svg)

\
&nbsp;

### Caveats

---

* The main workflow has been used for **research purposes** only.
* Analysis results should be interpreted with caution and should be treated as suspect.
* Binning quality is dependent on sequencing depth, genome complexity, and the reference databases used for taxonomic classification.
* **Low** `Bacterial_Confidence` assignments should be interpreted with caution.

\
&nbsp;

### Acknowledgements

---

We gratefully acknowledge the developers and maintainers of all tools used in this pipeline: **fastp**, **MEGAHIT**, **minimap2**, **VAMB**, **SemiBin2**, **MetaBat 2**, **Binette**, **CheckM2**, **GTDB-Tk**, **geNomad**, **AMRFinderPlus**, **CoverM**, and **MultiQC**.

We also acknowledge all data contributors who have shared reference genomes and metadata through **NCBI**, **GTDB**, and other public databases.

\
&nbsp;

### Disclaimer

---

**HFP, FDA** assumes no responsibility whatsoever for use by other parties of the Software, its source code, documentation or compiled or uncompiled executables, and makes no guarantees, expressed or implied, about its quality, reliability, or any other characteristic. Further, **HFP, FDA** makes no representations that the use of the Software will not infringe any patent or proprietary rights of third parties. The use of this code in no way implies endorsement by the **HFP, FDA** or confers any advantage in regulatory decisions.
