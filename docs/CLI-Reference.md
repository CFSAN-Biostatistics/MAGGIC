Show per-tool CLI options with `--help <tool>`:

```bash
./cpipes --pipeline maggic --help
```

## Available Tool Help

| Flag | Tool |
|------|------|
| `--help fastp` | fastp quality filtering options |
| `--help megahit` | MEGAHIT assembly options |
| `--help minimap2` | Minimap2 alignment options |
| `--help seb` | SemiBin2 `single_easy_bin` options |
| `--help vamb` | VAMB `bin def` options |
| `--help binette` | Binette consensus binning options |
| `--help gtdbtk` | GTDB-Tk `classify_wf` options |
| `--help abundance` | CoverM `genome` coverage options |
| `--help amrfinderplus` | AMRFinderPlus profiling options |
| `--help metabat2` | MetaBAT 2 binning options |

## Examples

```bash
# Show all tool help flags
./cpipes --pipeline maggic --help

# Show fastp options
./cpipes --pipeline maggic --help fastp

# Show multiple tools
./cpipes --pipeline maggic --help fastp,megahit
```

## Full Help Output

```bash
./cpipes --pipeline maggic --help

N E X T F L O W   ~  version 25.10.5

Launching `./cpipes` [distracted_panini] DSL2 - revision: 0a03b0b454

====================================================================================================             (o)
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
--help abundance                                       : Show CoverM `genome` CLI options
--help amrfinderplus                                   : Show AMRFinderPlus CLI options
--help metabat2                                        : Show metabat2 CLI options
