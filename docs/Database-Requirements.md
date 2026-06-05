The following databases are required before running the pipeline. All paths must be provided via command-line options or configuration files:

- **`GTDB-Tk` reference database** (`--gtdbtk_classify_wf_data_path`): Taxonomic classification of MAGs.
- **`CheckM2` database** (`--binette_checkm2_db`): Bin quality assessment in `Binette`.
- **`geNomad` database** (`--genomad_db`): Viral and plasmid element detection.
- **`AMRFinderPlus` database** (`--amrfinderplus_db`): Antimicrobial resistance gene profiling.

Download all from [research.foodsafetyrisk.org](https://research.foodsafetyrisk.org/maggic/dbs/maggic_dbs.tar.bz2).

Once downloaded, uncompress and set UNIX paths in `workflows/conf/maggic.config`:

- `binette_checkm2_db = /path/to/maggic_dbs/checkm2/latest`
- `gtdbtk_classify_wf_data_path = /path/to/gtdbtk/release232`
- `genomad_db = /path/to/maggic_dbs/genomad/latest/genomad_db`
- `amrfinderplus_db = /path/to/maggic_dbs/amrfinderplus/latest`

Setting database paths in the configuration file is the recommended approach, since it avoids specifying them via CLI on every run.
