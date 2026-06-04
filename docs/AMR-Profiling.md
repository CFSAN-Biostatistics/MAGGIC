# AMR Profiling

MAGGIC profiles antimicrobial resistance genes using **AMRFinderPlus**, running on refined MAGs after binning and quality assessment.

## Output Columns

| Column | Description |
|--------|-------------|
| `AMR_Gene_Count` | Number of hits with Type == "AMR" or Type == "STRESS" (excludes DISINFECTANT and HEAVY_METAL) |
| `AMR_Classes` | Semicolon-separated unique AMR classes (e.g., `Beta-Lactam;Aminoglycoside`) |
| `AMR_Genes` | Semicolon-separated unique gene symbols (e.g., `blaTEM-1;aadA`) |

## Database

AMRFinderPlus requires a local reference database. Set the path via `--amrfinderplus_db` or in `workflows/conf/maggic.config`:

```
amrfinderplus_db = /path/to/maggic_dbs/amrfinderplus/latest
```

See [[Database-Requirements]] for download instructions.

## MultiQC Integration

The AMR summary appears in the MultiQC Data Summary cards and the Chromosome/Plasmid result tables. Total AMR gene counts and unique classes are aggregated across all bins.