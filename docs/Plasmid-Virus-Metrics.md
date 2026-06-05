## Plasmid_Fraction

Fraction of total contigs with `plasmid_score >= 0.75`. Uses `Binette` contig_count as denominator, not plasmid_summary.tsv row count.

## Plasmid_Length_Weighted_Score

Length-weighted mean of `plasmid_score` across contigs: `sum(score_i * length_i) / sum(length_i)`. Falls back to simple mean if lengths unavailable. In plasmid TSV output, column is renamed to `Length_Weighted_Score`.

## Plasmid_Signal_Uniformity

Measures how uniformly the plasmid signal is distributed across contigs. Uses the same scoring as `PlasMAAG` (<a href="https://pubmed.ncbi.nlm.nih.gov/41639269/" target="_blank">Lindez *et al*. 2026</a>):

| Level | Length-Weighted Score | Minimum Score |
|-------|----------------------|---------------|
| **High** | >= 0.9 | >= 0.8 |
| **Medium** | >= 0.7 | >= 0.5 |
| **Low** | below Medium thresholds | |

**High** uniformity suggests all contigs carry a strong plasmid signal, consistent with a single replicon without chromosomal contamination.

## Virus_Length_Weighted_Score

Length-weighted mean of `virus_score` across contigs. In virus TSV output, renamed to `Length_Weighted_Score`.

## Virus_Signal_Uniformity

Analogous to plasmid uniformity, but **proviruses reduce confidence**. An integrated prophage within a chromosomal bin produces a less informative viral signal (<a href="https://doi.org/10.1038/s41587-023-01953-y" target="_blank">Camargo *et al*. 2024</a>).

| Level | Length-Weighted Score | Minimum Score | Proviruses |
|-------|----------------------|---------------|------------|
| **High** | >= 0.9 | >= 0.8 | None |
| **Medium** | High scores with proviruses present, OR moderate signal (>= 0.7 / >= 0.5) | | Any |
| **Low** | below Medium thresholds | | Any |

## Provirus Handling

| Column | Description |
|--------|-------------|
| `Provirus_Count` | Contigs with topology == `Provirus`; potentially integrated into the bin |
| `Provirus_Fraction` | provirus_count / virus_count |

Proviruses are common in bacterial chromosomes and do not trigger `Virus_MAG` classification when completeness >= 50%.

## Mobility_Potential

Pipe-separated evidence summary. Components appended only if present; `none` if no MGE evidence:

```
plasmid:High|virus:Low|proviruses:2|mob:Relaxed,Mobilized
```

The `mob` types come from `geNomad` `plasmid_summary.tsv`.
