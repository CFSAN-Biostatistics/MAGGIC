## Multi-Sample Binning with Strata Control

`MAGGIC` implements **strata-limited multi-sample binning**, a computationally efficient approach that improves MAG recovery while keeping alignment counts tractable for large cohorts.

Multi-sample binning aligns reads from multiple samples against every assembled contig set, giving binning tools (`VAMB`, `SemiBin2`, `MetaBat 2`) cross-sample coverage profiles. As shown by <a href="https://doi.org/10.1038/s41467-025-57957-6" target="_blank">Han *et al*. 2025</a>, this recovers **41-43% more species and strains** compared to single-sample binning, including rare taxa and antibiotic resistance gene hosts.

However, traditional all-vs-all alignment produces N&sup2; BAM files (50 samples = 2,500 alignments; 100 samples = 10,000 alignments). Coverage diversity **saturates around 20-30 samples** for most metagenomic experiments; beyond that, marginal improvement occurs at exponentially increasing computational cost (<a href="https://doi.org/10.1038/s41467-025-57957-6" target="_blank">Han *et al*. 2025</a>; <a href="https://doi.org/10.1038/s41587-020-00777-4" target="_blank">Nissen *et al*. 2021</a>; <a href="https://doi.org/10.3389/fmicb.2022.869135" target="_blank">Haryono *et al*. 2022</a>).

## How It Works

`MAGGIC` selects a subset of `strata_size` samples (default 15) and aligns their reads to every assembly, producing `strata_size` &times; `N` BAM files instead of N&sup2;. Selection uses **staggered sampling**, which distributes selected samples uniformly across the full sorted sample list.

This avoids geographic selection bias. In runs where sample IDs encode spatial information (state prefixes, site codes, collection dates), taking the first N samples concentrates coverage from a single region. Geographic distance is the primary driver of beta diversity in environmental samples (<a href="https://doi.org/10.1038/s41467-024-55425-1" target="_blank">Cheng *et al*. 2024</a>; <a href="https://doi.org/10.1128/mbio.02844-24" target="_blank">Peng *et al*. 2025</a>).

For example, with 500 samples and `strata_size` = 15:

| Method | Selected indices | Geographic spread |
|--------|-----------------|-------------------|
| First-N (sequential) | 0, 1, 2, 3, ... 14 | 1-2 states if IDs are alphabetically ordered |
| Staggered intervals | 0, 33, 66, 99, ... 483 | ~15 states evenly distributed |

The binning algorithms (`VAMB`' variational autoencoder, `MetaBAT 2`' coverage clustering, `SemiBin2`'s graph neural network) learn from these co-abundance patterns (<a href="https://doi.org/10.1038/s41587-020-00777-4" target="_blank">Nissen *et al*. 2021</a>; <a href="https://doi.org/10.1038/s41467-025-57957-6" target="_blank">Han *et al*. 2025</a>).

### Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--multi_sample_strata` | `true` | Enable strata-limited mode (`true` by default. Set `false` for full all-vs-all) |
| `--strata_size` | `15` | Number of samples whose reads are aligned to each assembly |

## Computational Time Reduction

| Samples | Full All-vs-All | Strata (15) | Reduction |
|---------|----------------|-------------|-----------|
| 30 | 900 BAMs | 450 BAMs | 2x |
| 50 | 2,500 BAMs | 750 BAMs | 3.3x |
| 100 | 10,000 BAMs | 1,500 BAMs | 6.7x |
| 200 | 40,000 BAMs | 3,000 BAMs | 13.3x |
| 500 | 250,000 BAMs | 7,500 BAMs | 33.3x |

The default strata size of 15 balances cross-sample coverage diversity with compute cost. For highly diverse cohorts (e.g., environmental samples from disparate locations), increase `--strata_size` to 20-30. For homogeneous cohorts (e.g., clinical samples from the same body site), 10-15 is sufficient.

```bash
./cpipes \
    --pipeline maggic \
    --input /path/to/fastq/dir \
    --output /path/to/output \
    --strata_size 20 \
    -profile singularity \
    -resume
