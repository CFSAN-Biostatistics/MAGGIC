# Implementation Plan

[Overview]
Convert the existing 520-line `readme/maggic.md` into a GitHub Wiki with 10 pages organized in a logical hierarchy, including all 10 maggic-wand PNG plots and repo asset images (pipeline diagram, data cards screenshot).

The source document is a single monolithic markdown file. The Wiki will split content across pages for better navigation: users can jump to Results, Plots, or Usage without scrolling through unrelated sections. The wiki will be created as a local git repo at `/home/Kranti.Konganti/apps/maggic-wiki/`, ready for the user to add a remote URL later.

[Types]
No code types. The Wiki uses standard GitHub-flavored Markdown with `.wiki` file extension.

File naming convention: `Page-Name.wiki` (hyphens, no spaces). Cross-links use `[[Page-Name]]` wiki syntax.

[Files]
Create 10 wiki pages and copy 16 image assets into a new `/home/Kranti.Konganti/apps/maggic-wiki/` directory.

**New wiki pages (markdown, .wiki extension):**

| File | Source Section | Summary |
|------|---------------|---------|
| `Home.wiki` | Title, description, Pipeline Overview | Pipeline intro, diagram, quick link table |
| `Installation-Requirements.wiki` | Minimum Requirements | Nextflow, containers, memory, 20 cores |
| `Database-Requirements.wiki` | Database Requirements | GTDB-Tk, CheckM2, geNomad, AMRFinderPlus paths |
| `Multi-Sample-Binning.wiki` | Multi-Sample Binning with Strata Control | Staggered sampling, BAM reduction tables |
| `Results-Overview.wiki` | MAGGIC Results (MultiQC + output files) | Data cards screenshot, output TSV listing |
| `Bin-Classification.wiki` | Bin_Type Classification table, Bacterial_Confidence | geNomad scoring, completeness filter, confidence thresholds |
| `Plasmid-Virus-Metrics.wiki` | Plasmid_Signal_Uniformity, Virus_Signal_Uniformity, columns | Uniformity thresholds, provirus handling, Mobility_Potential |
| `AMR-Profiling.wiki` | AMR_Gene_Count, AMR_Classes, AMR_Genes columns | AMR column descriptions |
| `MAGGIC-Plots.wiki` | NEW — not in maggic.md | All 10 PNG images with captions |
| `Usage-Examples.wiki` | Usage and Examples, Runtime profiles, Cloud | CLI examples, input/output, profiles, cloud config |
| `CLI-Reference.wiki` | maggic CLI Help | Per-tool help listing |

**Image assets (copy to `assets/` subdirectory in wiki):**

From `/home/Kranti.Konganti/apps/maggic/assets/`:
- `maggic_pipeline_diagram.svg` → Home page
- `maggic_datasum_cards.png` → Results-Overview page
- `maggic-icon.svg` → Home page (logo)

From `/home/Kranti.Konganti/apps/maggic-wand/`:
- All 10 `*.png` files → MAGGIC-Plots page

**directory structure:**
```
maggic-wiki/
├── .git/
├── Home.wiki
├── Installation-Requirements.wiki
├── Database-Requirements.wiki
├── Multi-Sample-Binning.wiki
├── Results-Overview.wiki
├── Bin-Classification.wiki
├── Plasmid-Virus-Metrics.wiki
├── AMR-Profiling.wiki
├── MAGGIC-Plots.wiki
├── Usage-Examples.wiki
├── CLI-Reference.wiki
└── assets/
    ├── maggic_pipeline_diagram.svg
    ├── maggic_datasum_cards.png
    ├── maggic-icon.svg
    ├── amr_class_donut.png
    ├── amr_wordcloud.png
    ├── completeness_contig_scatter.png
    ├── genus_diversity.png
    ├── genus_heatmap.png
    ├── mge_radar.png
    ├── quality_ecdf.png
    ├── quality_scatter.png
    ├── species_diversity.png
    └── species_heatmap.png
```

[Functions]
No functions. This is a documentation task.

[Classes]
No classes. This is a documentation task.

[Dependencies]
- `git`: Initialize repo and commit wiki pages
- `cp`: Copy image assets from two source directories
- `mkdir`: Create output directory and assets folder

[Testing]
- Verify all internal `[[WikiLink]]` cross-references resolve to existing `.wiki` files
- Verify all image paths (`assets/...`) exist after copy
- Verify Home.wiki sidebar includes all page links
- Run `ls -la` on output directory to confirm 11 `.wiki` files + `assets/` folder with 13 images

[Implementation Order]
1. Create `/home/Kranti.Konganti/apps/maggic-wiki/` and initialize git repo
2. Copy all 13 image assets to `assets/` subdirectory
3. Create `Home.wiki` — overview, logo, diagram, navigation table
4. Create `Installation-Requirements.wiki` — system requirements and setup
5. Create `Database-Requirements.wiki` — reference database paths
6. Create `Multi-Sample-Binning.wiki` — strata control with tables
7. Create `Results-Overview.wiki` — MultiQC report, output files, TSV columns
8. Create `Bin-Classification.wiki` — Bin_Type logic, confidence thresholds
9. Create `Plasmid-Virus-Metrics.wiki` — uniformity scores, proviruses, mobility
10. Create `AMR-Profiling.wiki` — AMR columns
11. Create `MAGGIC-Plots.wiki` — 10 images with descriptive captions
12. Create `Usage-Examples.wiki` — CLI usage, profiles, cloud
13. Create `CLI-Reference.wiki` — help output
14. Verify all cross-links and image paths
15. Commit all files with initial commit