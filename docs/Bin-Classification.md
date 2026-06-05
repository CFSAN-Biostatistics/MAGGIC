Bins are classified using a multi-signal approach based on `geNomad` scores, with a biologically grounded completeness filter.

## `geNomad` Classification Accuracy

- **Plasmid**: Precision 70.8%, Sensitivity 89.8% (<a href="https://doi.org/10.1038/s41587-023-01953-y" target="_blank">Camargo *et al*. 2024</a>). Nearly one third of contigs called plasmid are potentially false positives.
- **Virus**: MCC 95.3%, F1 97.3% — strong classification.

`geNomad` runs in default mode so ALL contigs receive plasmid/virus scores where possible. Official filtering presets: default (min-score=0.70), conservative (min-score=0.80), relaxed (min-score=0.00).

**Important**: `geNomad` output files contain only positive predictions. Contigs not flagged as viral or plasmid do not appear in `virus_summary.tsv` or `plasmid_summary.tsv`.

## Hard Completeness Filter (>= 50%)

`CheckM2` uses ~20,000 KEGG orthologs for chromosomal housekeeping functions (<a href="https://doi.org/10.1038/s41592-023-02017-3" target="_blank">Chklovski *et al*. 2023</a>). Plasmids and viruses typically do not carry these markers. Therefore, a bin with completeness >= 50% likely contains chromosomal DNA and MAGGIC does not classify it as a pure `Plasmid_MAG` or `Virus_MAG`.

### When Completeness >= 50%

| MAGGIC Classification | Criteria |
|-----------------------|----------|
| `Mixed_MAG` | `geNomad` `plasmid_summary.tsv` has contigs with plasmid_score >= 0.75 AND count / total_contigs >= 0.2 (using `Binette` contig_count as denominator) |
| `Chromosome_MAG` | No contigs with plasmid_score >= 0.75, OR plasmid_fraction < 0.2. Also assigned when virus_summary.tsv exists but only proviruses are present |

### When Completeness < 50%

| MAGGIC Classification | Criteria |
|-----------------------|----------|
| `Virus_MAG` | `geNomad` `virus_summary.tsv` has any entries (checked first — virus model is most reliable) |
| `Plasmid_MAG` | `geNomad` `plasmid_summary.tsv` has entries but virus_summary.tsv has none |
| `Chromosome_MAG` | Neither `geNomad` plasmid nor virus summaries have entries |

## Bacterial_Confidence Thresholds

| Level | Completeness | Contamination | ANI | AF |
|-------|-------------|---------------|-----|----|
| **High** | >= 90% | < 5% | >= 95% | >= 0.65 |
| **Medium** | >= 50% | < 10% | >= 80% | >= 0.50 |
| **Low** | below Medium thresholds | | | |

Thresholds are configurable via CLI options: `--high-comp`, `--high-contam`, `--high-ani`, `--high-af`, `--med-comp`, `--med-contam`, `--med-ani`, `--med-af`.
