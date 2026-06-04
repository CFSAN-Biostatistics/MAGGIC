# MAGGIC

MAGGIC (**M**etagenomically **A**ssembled **G**enome **G**eneration with **I**ntegrated **C**lassification) is an automated workflow for the generation and refinement of Metagenome-Assembled Genomes (MAGs) from metagenomic sequencing data.

It integrates multiple binning algorithms (VAMB, SemiBin2, MetaBat 2) followed by consensus-based bin refinement with Binette, taxonomic classification with GTDB-Tk, mobile genetic element detection with geNomad, and antimicrobial resistance gene profiling with AMRFinderPlus.

![MAGGIC Pipeline Overview](assets/maggic_pipeline_diagram.svg)

## Quick Links

| Topic | Page |
|-------|------|
| System setup | [[Installation-Requirements]] |
| Reference databases | [[Database-Requirements]] |
| Strata-limited binning | [[Multi-Sample-Binning]] |
| Results and output files | [[Results-Overview]] |
| Bin type classification | [[Bin-Classification]] |
| Plasmid & virus metrics | [[Plasmid-Virus-Metrics]] |
| AMR profiling | [[AMR-Profiling]] |
| Diagnostic plots | [[MAGGIC-Plots]] |
| Run the pipeline | [[Usage-Examples]] |
| Per-tool CLI options | [[CLI-Reference]] |
| Future roadmap | [#future-roadmap](#future-roadmap) |

## Future Roadmap

- 06/04/2026: Will address BAM low depth issues in later versions. <1% mapped && <100K reads && <5000 contigs will be filtered out.