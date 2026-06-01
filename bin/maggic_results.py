#!/usr/bin/env python3
#
# Kranti Konganti
#
# 05/15/2026
# (C) HFP, FDA
#

import argparse
import csv
import json
import math
import os
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional, Set, Tuple

import yaml


def parse_args() -> argparse.Namespace:
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Aggregate MAGGIC bin results into a single summary table.",
        epilog="Input directory should contain geNomad, AMRFinderPlus, GTDB-Tk, "
        "and Binette outputs for all bins.",
    )
    parser.add_argument("input_dir", help="Directory containing all bin result files")
    parser.add_argument(
        "-o",
        "--output",
        default="maggic-results.tsv",
        help="Output TSV file path (default: maggic-results.tsv)",
    )
    parser.add_argument(
        "--min-virus-score",
        type=float,
        default=0.9,
        help="Minimum virus score for high-confidence viral elements (default: 0.9)",
    )
    parser.add_argument(
        "--min-plasmid-score",
        type=float,
        default=0.9,
        help="Minimum plasmid score for high-confidence plasmid elements (default: 0.9)",
    )
    parser.add_argument(
        "--max-fdr",
        type=float,
        default=10.0,
        help="Maximum FDR percentage for high-confidence elements (default: 10.0)",
    )
    parser.add_argument(
        "--high-comp",
        type=float,
        default=90.0,
        help="Min completeness for High confidence (default: 90.0)",
    )
    parser.add_argument(
        "--high-contam",
        type=float,
        default=5.0,
        help="Max contamination for High confidence (default: 5.0)",
    )
    parser.add_argument(
        "--high-ani",
        type=float,
        default=95.0,
        help="Min ANI for High confidence (default: 95.0)",
    )
    parser.add_argument(
        "--high-af",
        type=float,
        default=0.65,
        help="Min AF for High confidence (default: 0.65)",
    )
    parser.add_argument(
        "--med-comp",
        type=float,
        default=50.0,
        help="Min completeness for Medium confidence (default: 50.0)",
    )
    parser.add_argument(
        "--med-contam",
        type=float,
        default=10.0,
        help="Max contamination for Medium confidence (default: 10.0)",
    )
    parser.add_argument(
        "--med-ani",
        type=float,
        default=80.0,
        help="Min ANI for Medium confidence (default: 80.0)",
    )
    parser.add_argument(
        "--med-af",
        type=float,
        default=0.5,
        help="Min AF for Medium confidence (default: 0.5)",
    )
    parser.add_argument(
        "--cov-merged",
        default="maggic-globalabundance.tsv",
        help="Output TSV file for merged CoverM abundance (default: maggic-globalabundance.tsv)",
    )
    return parser.parse_args()


# Output column definitions
HEADER: List[str] = [
    "Name",
    "Bin_Type",
    "Bacterial_Confidence",
    "Taxonomy",
    "Completeness",
    "Contamination",
    "Closest_Ref_ANI",
    "Closest_Ref_AF",
    "Genome_Size",
    "Total_Contigs",
    "GC_Content",
    "N50",
    "Coding_Density",
    "Plasmid_Fraction",
    "Plasmid_Length_Weighted_Score",
    "Plasmid_Signal_Uniformity",
    "Virus_Length_Weighted_Score",
    "Virus_Count",
    "High_Conf_Viruses",
    "Virus_Signal_Uniformity",
    "Provirus_Count",
    "Provirus_Fraction",
    "Mobility_Potential",
    "Virus_Taxonomy",
    "Plasmid_Count",
    "High_Conf_Plasmids",
    "Conjugation_Genes",
    "AMR_Gene_Count",
    "AMR_Classes",
    "AMR_Genes",
]


def discover_bins(input_dir: str, output_file: Optional[str] = None) -> List[str]:
    """Find all unique bin names from result files in the input directory."""
    bins: Set[str] = set()
    input_path = Path(input_dir)

    # Files to exclude from bin discovery
    excluded_files: Set[str] = {
        "ALL_REFINED_BINS_QUALITY_REPORT.tsv",
        "maggic-globalabundance.tsv",
        "maggic-results.tsv",
        "maggic-results-chromosome.tsv",
        "maggic-results-plasmid.tsv",
        "maggic-results-virus.tsv",
        "maggic-results-datasum.json",
    }
    if output_file:
        excluded_files.add(Path(output_file).name)

    for fpath in input_path.iterdir():
        name = fpath.name

        if name in excluded_files:
            continue

        # geNomad virus files: bin_virus_summary.tsv
        if name.endswith("_virus_summary.tsv"):
            bin_name = name.replace("_virus_summary.tsv", "")
            bins.add(bin_name)

        # geNomad plasmid files: bin_plasmid_summary.tsv
        elif name.endswith("_plasmid_summary.tsv"):
            bin_name = name.replace("_plasmid_summary.tsv", "")
            bins.add(bin_name)

        # AMRFinderPlus: bin.tsv (but not summary files, not CoverM files)
        elif (
            name.endswith(".tsv")
            and "_summary" not in name
            and not name.endswith(".coverm.tsv")
        ):
            bin_name = name.replace(".tsv", "")
            bins.add(bin_name)

        # GTDB-Tk directories: contains gtdbtk.bac120.summary.tsv
        elif fpath.is_dir() and "gtdbtk" in name.lower():
            bac_file = fpath / "gtdbtk.bac120.summary.tsv"
            if bac_file.exists():
                try:
                    with open(bac_file, "r") as f:
                        reader = csv.DictReader(f, delimiter="\t")
                        for row in reader:
                            bin_name = row.get("user_genome", "")
                            if bin_name:
                                bins.add(bin_name)
                except (csv.Error, KeyError, OSError):
                    pass

    # Binette quality report (single collected file from Nextflow)
    quality_file = input_path / "ALL_REFINED_BINS_QUALITY_REPORT.tsv"
    if quality_file.exists():
        try:
            with open(quality_file, "r") as f:
                reader = csv.DictReader(f, delimiter="\t")
                for row in reader:
                    bin_name = row.get("name", "")
                    if bin_name:
                        bins.add(bin_name)
        except (csv.Error, KeyError, OSError):
            pass

    return sorted(bins)


def parse_binette_quality(input_dir: str) -> Dict[str, Dict[str, str]]:
    """Read quality metrics from Binette quality report."""
    quality: Dict[str, Dict[str, str]] = {}
    quality_file = Path(input_dir) / "ALL_REFINED_BINS_QUALITY_REPORT.tsv"

    if not quality_file.exists():
        return quality

    try:
        with open(quality_file, "r") as f:
            reader = csv.DictReader(f, delimiter="\t")
            for row in reader:
                bin_name = row.get("name", "")
                if not bin_name:
                    continue
                quality[bin_name] = {
                    "completeness": row.get("completeness", "NA"),
                    "contamination": row.get("contamination", "NA"),
                    "size": row.get("size", "NA"),
                    "contig_count": row.get("contig_count", "NA"),
                    "n50": row.get("N50", "NA"),
                    "coding_density": row.get("coding_density", "NA"),
                }
    except (csv.Error, KeyError, OSError):
        pass

    return quality


def parse_gtdbtk(input_dir: str, bin_name: str) -> Dict[str, str]:
    """Parse GTDB-Tk classification for a single bin."""
    result: Dict[str, str] = {
        "taxonomy": "NA",
        "closest_ani": "NA",
        "closest_af": "NA",
    }

    input_path = Path(input_dir)

    for dirpath in input_path.iterdir():
        if not dirpath.is_dir():
            continue
        bac_file = dirpath / "gtdbtk.bac120.summary.tsv"
        if not bac_file.exists():
            continue

        try:
            with open(bac_file, "r") as f:
                reader = csv.DictReader(f, delimiter="\t")
                for row in reader:
                    if row.get("user_genome", "") == bin_name:
                        classification = row.get("classification", "NA")
                        if (
                            classification
                            and classification != "NA"
                            and classification.strip()
                        ):
                            result["taxonomy"] = classification.strip()

                        ani = row.get("closest_genome_ani", "NA")
                        af = row.get("closest_genome_af", "NA")
                        result["closest_ani"] = ani if ani and ani.strip() else "NA"
                        result["closest_af"] = af if af and af.strip() else "NA"
                        break
        except (csv.Error, KeyError):
            break

    return result


def parse_genomad_virus(
    input_dir: str,
    bin_name: str,
    min_virus_score: float,
    max_fdr: float,
) -> Dict[str, Any]:
    """Parse geNomad virus summary for a single bin."""
    result: Dict[str, Any] = {
        "file_found": False,
        "virus_count": 0,
        "high_conf_viruses": 0,
        "virus_taxonomies": set(),
        "virus_scores": [],
        "provirus_count": 0,
        "provirus_max_score": 0.0,
        "virus_lengths": [],
        "virus_contig_names": [],
    }

    virus_file = Path(input_dir) / f"{bin_name}_virus_summary.tsv"
    if not virus_file.exists():
        return result

    result["file_found"] = True

    try:
        with open(virus_file, "r") as f:
            reader = csv.DictReader(f, delimiter="\t")
            for row in reader:
                result["virus_count"] += 1

                topology = row.get("topology", "")
                if topology and topology.strip() == "Provirus":
                    result["provirus_count"] += 1
                    score_str = row.get("virus_score", "0")
                    try:
                        score_val = float(score_str)
                        if score_val > result["provirus_max_score"]:
                            result["provirus_max_score"] = score_val
                    except (ValueError, TypeError):
                        pass

                taxonomy = row.get("taxonomy", "NA")
                if taxonomy and taxonomy != "NA" and taxonomy.strip():
                    result["virus_taxonomies"].add(taxonomy.strip())

                score = row.get("virus_score", "0")
                fdr = row.get("fdr", "NA")
                try:
                    score_val = float(score)
                    result["virus_scores"].append(score_val)

                    # Track contig length for length-weighted scoring
                    len_str = row.get("length", "0")
                    try:
                        contig_len = int(len_str)
                        result["virus_lengths"].append(contig_len)
                        result["virus_contig_names"].append(
                            row.get("seq_name", "unknown")
                        )
                    except (ValueError, TypeError):
                        result["virus_lengths"].append(0)
                        result["virus_contig_names"].append(
                            row.get("seq_name", "unknown")
                        )
                    if fdr and fdr != "NA" and fdr.strip():
                        fdr_val = float(fdr)
                        if score_val >= min_virus_score and fdr_val <= max_fdr:
                            result["high_conf_viruses"] += 1
                    else:
                        if score_val >= min_virus_score:
                            result["high_conf_viruses"] += 1
                except (ValueError, TypeError):
                    pass
    except (csv.Error, KeyError, OSError):
        pass

    return result


def parse_genomad_plasmid(
    input_dir: str,
    bin_name: str,
    min_score: float,
    max_fdr: float,
) -> Dict[str, Any]:
    """Parse geNomad plasmid summary for a single bin."""
    result: Dict[str, Any] = {
        "file_found": False,
        "plasmid_count": 0,
        "high_conf_plasmids": 0,
        "conjugation_types": set(),
        "plasmid_scores": [],
        "total_contigs_scored": 0,
        "plasmid_lengths": [],
        "plasmid_contig_names": [],
    }

    plasmid_file = Path(input_dir) / f"{bin_name}_plasmid_summary.tsv"
    if not plasmid_file.exists():
        return result

    result["file_found"] = True

    try:
        with open(plasmid_file, "r") as f:
            reader = csv.DictReader(f, delimiter="\t")
            for row in reader:
                result["plasmid_count"] += 1
                result["total_contigs_scored"] += 1

                score = row.get("plasmid_score", "0")
                fdr = row.get("fdr", "NA")
                try:
                    score_val = float(score)
                    result["plasmid_scores"].append(score_val)

                    # Track contig length for length-weighted scoring
                    len_str = row.get("length", "0")
                    try:
                        contig_len = int(len_str)
                        result["plasmid_lengths"].append(contig_len)
                        result["plasmid_contig_names"].append(
                            row.get("seq_name", "unknown")
                        )
                    except (ValueError, TypeError):
                        result["plasmid_lengths"].append(0)
                        result["plasmid_contig_names"].append(
                            row.get("seq_name", "unknown")
                        )
                    if fdr and fdr != "NA" and fdr.strip():
                        fdr_val = float(fdr)
                        if score_val >= min_score and fdr_val <= max_fdr:
                            result["high_conf_plasmids"] += 1
                    else:
                        if score_val >= min_score:
                            result["high_conf_plasmids"] += 1
                except (ValueError, TypeError):
                    pass

                mob = row.get("conjugation_genes", "NA")
                if mob and mob != "NA" and mob.strip():
                    for mob_type in mob.split(","):
                        mob_type = mob_type.strip()
                        if mob_type and mob_type != "NA":
                            result["conjugation_types"].add(mob_type)
    except (csv.Error, KeyError, OSError):
        pass

    return result


def parse_amrfinderplus(input_dir: str, bin_name: str) -> Dict[str, Any]:
    """Parse AMRFinderPlus results for a single bin."""
    result: Dict[str, Any] = {
        "file_found": False,
        "amr_count": 0,
        "amr_classes": set(),
        "amr_genes": [],
    }

    amr_file = Path(input_dir) / f"{bin_name}.tsv"
    if not amr_file.exists():
        return result

    result["file_found"] = True

    try:
        with open(amr_file, "r") as f:
            reader = csv.DictReader(f, delimiter="\t")
            for row in reader:
                gene_type = row.get("Type", "")
                if gene_type in ("AMR", "STRESS"):
                    result["amr_count"] += 1
                    symbol = row.get("Element symbol", "NA")
                    amr_class = row.get("Class", "NA")

                    if symbol and symbol != "NA" and symbol.strip():
                        result["amr_genes"].append(symbol.strip())
                    if amr_class and amr_class != "NA" and amr_class.strip():
                        result["amr_classes"].add(amr_class.strip())
    except (csv.Error, KeyError, OSError):
        pass

    return result


def _safe_float(val: Any, default: float = 0.0) -> float:
    """Convert value to float, returning default for NA/N/A/empty."""
    if val and val not in ("NA", "N/A") and str(val).strip():
        try:
            return float(val)
        except (ValueError, TypeError):
            return default
    return default


# Plasmid_Signal_Uniformity and Virus_Signal_Uniformity measure how
# uniform the plasmid/virus signal is across contigs in a bin, computed from
# geNomad plasmid_score / virus_score distributions, and returns High/Medium/Low/NA.


def compute_plasmid_signal_uniformity(
    plasmid_scores: List[float],
    plasmid_lengths: List[int],
) -> str:
    """Estimate how uniformly plasmid-like contigs are within a bin.

    High: length-weighted score >= 0.9 AND min score >= 0.8
    Medium: length-weighted score >= 0.7 AND min score >= 0.5
    Low: weak or mixed signal
    """
    if not plasmid_scores:
        return "NA"

    total_len = sum(plasmid_lengths) if plasmid_lengths else 0
    if total_len > 0:
        lw_score = (
            sum(s * l for s, l in zip(plasmid_scores, plasmid_lengths)) / total_len
        )
    else:
        lw_score = sum(plasmid_scores) / len(plasmid_scores)

    min_score = min(plasmid_scores)

    if lw_score >= 0.9 and min_score >= 0.8:
        return "High"
    elif lw_score >= 0.7 and min_score >= 0.5:
        return "Medium"
    else:
        return "Low"


def compute_virus_signal_uniformity(
    virus_scores: List[float],
    virus_lengths: List[int],
    provirus_count: int,
    provirus_max_score: float,
) -> str:
    """Estimate how uniformly viral contigs are within a bin.

    High: length-weighted score >= 0.9 AND min score >= 0.8 AND no proviruses
    Medium: high scores with proviruses present OR moderate signal
    Low: weak or mixed signal
    """
    if not virus_scores:
        return "NA"

    total_len = sum(virus_lengths) if virus_lengths else 0
    if total_len > 0:
        lw_score = sum(s * l for s, l in zip(virus_scores, virus_lengths)) / total_len
    else:
        lw_score = sum(virus_scores) / len(virus_scores)

    min_score = min(virus_scores)
    has_proviruses = provirus_count > 0

    # Strong signal with no proviruses suggests a single replicon
    if lw_score >= 0.9 and min_score >= 0.8:
        if not has_proviruses:
            return "High"
        else:
            # Proviruses present may reduce confidence (possible integrated prophage)
            return "Medium"
    elif lw_score >= 0.7 and min_score >= 0.5:
        return "Medium"
    else:
        return "Low"


# Build a human-readable mobility potential string from plasmid/virus signals.


def build_mobility_potential(
    plasmid_homogeneity: str,
    virus_homogeneity: str,
    provirus_count: int,
    conjugation_types: Set[str],
) -> str:
    """Build a pipe-separated mobility potential summary."""
    parts: List[str] = []

    if plasmid_homogeneity != "NA":
        parts.append(f"plasmid:{plasmid_homogeneity}")
    if virus_homogeneity != "NA":
        parts.append(f"virus:{virus_homogeneity}")
    if provirus_count > 0:
        parts.append(f"proviruses:{provirus_count}")
    if conjugation_types:
        parts.append(f"mob:{','.join(sorted(conjugation_types))}")

    if not parts:
        return "none"

    return "|".join(parts)


# Weighted average where longer contigs count more.


def _length_weighted_mean(
    scores: List[float],
    lengths: List[int],
) -> float:
    """Compute length-weighted mean of scores.

    Weighted score = sum(score_i * length_i) / sum(length_i)
    Falls back to simple mean if lengths are all zero or empty.
    """
    if not scores:
        return float("nan")

    total_len = sum(lengths) if lengths else 0
    if total_len > 0:
        return sum(s * l for s, l in zip(scores, lengths)) / total_len
    else:
        return sum(scores) / len(scores)


def classify_bin_type(
    plasmid_scores: List[float],
    virus_scores: List[float],
    completeness: float = 0.0,
    contig_count: int = 0,
    genomad_thr: float = 0.75,
) -> str:
    """
    Classify bin as Plasmid_MAG, Virus_MAG, Mixed_MAG, or Chromosome_MAG.

    Completeness >= 50% likely indicates chromosomal DNA: CheckM2 uses
    chromosomal markers (PMID: 37500759); bins above this threshold may be
    Chromosome_MAG or, if they carry plasmid contigs with sufficient
    fraction, Mixed_MAG.
    """
    is_chromosomal_quality = completeness >= 50.0

    # No mobile element signal at all; pure chromosomal bin
    if not plasmid_scores and not virus_scores:
        return "Chromosome_MAG"

    if is_chromosomal_quality:
        if not plasmid_scores:
            return "Chromosome_MAG"

        # Fraction uses total contig count, not plasmid_summary row count
        # (geNomad tsv has only positives). Threshold 0.75 matches Plasmid_Fraction.
        plasmid_high = sum(1 for s in plasmid_scores if s >= 0.75)
        plasmid_fraction = plasmid_high / max(contig_count, 1)
        if plasmid_fraction >= 0.2:
            return "Mixed_MAG"
        else:
            return "Chromosome_MAG"

    # Low completeness bins may be plasmid or virus bins
    # Virus model is more reliable (MCC 95.3% vs plasmid MCC 70.8%)
    if virus_scores:
        return "Virus_MAG"

    if plasmid_scores:
        return "Plasmid_MAG"

    return "Chromosome_MAG"


# Compute bacterial confidence (High/Medium/Low) from quality and taxonomy metrics.


def compute_bacterial_confidence(
    completeness: str,
    contamination: str,
    ani: str,
    af: str,
    high_comp: float,
    high_contam: float,
    high_ani: float,
    high_af: float,
    med_comp: float,
    med_contam: float,
    med_ani: float,
    med_af: float,
) -> str:
    """Compute bacterial confidence from quality and taxonomy metrics."""
    comp = _safe_float(completeness)
    contam = _safe_float(contamination)
    ani_val = _safe_float(ani)
    af_val = _safe_float(af)

    if (
        comp >= high_comp
        and contam < high_contam
        and ani_val >= high_ani
        and af_val >= high_af
    ):
        return "High"

    if (
        comp >= med_comp
        and contam < med_contam
        and ani_val >= med_ani
        and af_val >= med_af
    ):
        return "Medium"

    return "Low"


# Parse and merge CoverM coverage files into a global abundance matrix.


def _parse_coverm_file(
    coverm_file: Path,
) -> Tuple[List[str], List[str]]:
    """Parse a single CoverM TSV file.

    Returns (bin_names, coverage_values). Skips header row.
    First column is bin name, second column is coverage value.
    Uses positional parsing since sample column name varies.
    """
    bin_names: List[str] = []
    coverage_values: List[str] = []

    try:
        with open(coverm_file, "r") as f:
            header = f.readline()
            for line in f:
                parts = line.rstrip("\n").split("\t")
                if len(parts) >= 2:
                    bin_names.append(parts[0])
                    coverage_values.append(parts[1])
    except OSError:
        pass

    return bin_names, coverage_values


def _verify_consistent_bins(
    coverm_files: Dict[str, Tuple[List[str], List[str]]],
) -> bool:
    """Verify all CoverM files have identical bin names in the same order."""
    if not coverm_files:
        return False

    first_key = next(iter(coverm_files))
    reference_bins = coverm_files[first_key][0]

    if not reference_bins:
        return False

    for key, (bin_names, _) in coverm_files.items():
        if key == first_key:
            continue
        if bin_names != reference_bins:
            return False

    return True


def _merge_coverm_columns(
    coverm_files: Dict[str, Tuple[List[str], List[str]]],
    output_file: str,
) -> None:
    """Merge coverage values column-wise into output TSV."""
    if not coverm_files:
        return

    first_key = next(iter(coverm_files))
    reference_bins = coverm_files[first_key][0]

    sample_names = sorted(coverm_files.keys())

    try:
        with open(output_file, "w", newline="") as f:
            writer = csv.writer(f, delimiter="\t")

            writer.writerow(["Genome"] + sample_names)

            for i, bin_name in enumerate(reference_bins):
                row = [bin_name]
                for sample_name in sample_names:
                    _, coverage_values = coverm_files[sample_name]
                    row.append(coverage_values[i])
                writer.writerow(row)
    except OSError:
        pass


def discover_coverm_abn_results(
    input_dir: str, output_file: Optional[str] = None
) -> List[Dict[str, str]]:
    """Find and merge all *.coverm.tsv files into a global abundance matrix."""
    coverm_files: Dict[str, Tuple[List[str], List[str]]] = {}
    input_path = Path(input_dir)

    for coverm_file in sorted(input_path.glob("*.coverm.tsv")):
        sample_name = coverm_file.name.replace(".coverm.tsv", "")
        bin_names, coverage_values = _parse_coverm_file(coverm_file)
        if bin_names:
            coverm_files[sample_name] = (bin_names, coverage_values)

    if not coverm_files:
        return []

    if not _verify_consistent_bins(coverm_files):
        return []

    out_file = output_file if output_file else "maggic-globalabundance.tsv"

    _merge_coverm_columns(coverm_files, out_file)

    results: List[Dict[str, str]] = []
    first_key = next(iter(coverm_files))
    reference_bins = coverm_files[first_key][0]
    sample_names = sorted(coverm_files.keys())

    for i, bin_name in enumerate(reference_bins):
        row: Dict[str, str] = {"Genome": bin_name}
        for sample_name in sample_names:
            _, coverage_values = coverm_files[sample_name]
            row[sample_name] = coverage_values[i]
        results.append(row)

    return results


# Parse all result files for all bins and merge into a single dict list.


def aggregate_all(
    input_dir: str,
    min_virus_score: float,
    min_plasmid_score: float,
    output_file: Optional[str] = None,
    max_fdr: float = 10.0,
    high_comp: float = 90.0,
    high_contam: float = 5.0,
    high_ani: float = 95.0,
    high_af: float = 0.65,
    med_comp: float = 50.0,
    med_contam: float = 10.0,
    med_ani: float = 80.0,
    med_af: float = 0.5,
) -> List[Dict[str, Any]]:
    """Orchestrate parsing and merge all data sources."""
    bins = discover_bins(input_dir, output_file)
    quality = parse_binette_quality(input_dir)
    max_fdr_decimal = max_fdr / 100.0

    results: List[Dict[str, Any]] = []

    for bin_name in bins:
        row: Dict[str, Any] = {"Name": bin_name}

        q = quality.get(bin_name, {})
        row["Completeness"] = q.get("completeness", "NA")
        row["Contamination"] = q.get("contamination", "NA")
        row["Genome_Size"] = q.get("size", "NA")
        row["Total_Contigs"] = q.get("contig_count", "NA")
        row["GC_Content"] = "NA"
        row["N50"] = q.get("n50", "NA")
        row["Coding_Density"] = q.get("coding_density", "NA")

        g = parse_gtdbtk(input_dir, bin_name)
        row["Taxonomy"] = g["taxonomy"]
        row["Closest_Ref_ANI"] = g["closest_ani"]
        row["Closest_Ref_AF"] = g["closest_af"]

        row["Bacterial_Confidence"] = compute_bacterial_confidence(
            q.get("completeness", "NA"),
            q.get("contamination", "NA"),
            g["closest_ani"],
            g["closest_af"],
            high_comp,
            high_contam,
            high_ani,
            high_af,
            med_comp,
            med_contam,
            med_ani,
            med_af,
        )

        v = parse_genomad_virus(input_dir, bin_name, min_virus_score, max_fdr_decimal)
        # Use NA when geNomad virus file not present
        if v["file_found"]:
            row["Virus_Count"] = v["virus_count"]
            row["High_Conf_Viruses"] = v["high_conf_viruses"]
            row["Provirus_Count"] = v["provirus_count"]
        else:
            row["Virus_Count"] = "NA"
            row["High_Conf_Viruses"] = "NA"
            row["Provirus_Count"] = "NA"

        # Provirus_Fraction: proportion of viral contigs that are integrated
        if v["virus_count"] > 0:
            row["Provirus_Fraction"] = round(v["provirus_count"] / v["virus_count"], 3)
        else:
            row["Provirus_Fraction"] = "NA"

        row["Virus_Taxonomy"] = (
            ";".join(sorted(v["virus_taxonomies"])) if v["virus_taxonomies"] else "NA"
        )

        p = parse_genomad_plasmid(
            input_dir, bin_name, min_plasmid_score, max_fdr_decimal
        )

        # Plasmid_Fraction: proportion of contigs with plasmid_score >= 0.75.
        # Denominator is Binette contig_count, not plasmid_summary row count
        # (geNomad tsv has only positives).
        contig_total = int(_safe_float(q.get("contig_count", "0")))
        if contig_total > 0:
            plasmid_high = sum(1 for s in p["plasmid_scores"] if s >= 0.75)
            row["Plasmid_Fraction"] = round(plasmid_high / contig_total, 3)
        else:
            row["Plasmid_Fraction"] = "NA"

        # Plasmid_Length_Weighted_Score: length-weighted ensemble (PlasMAAG-style)
        # Replaces Mean_Plasmid_Score
        if p["plasmid_scores"]:
            lw = _length_weighted_mean(p["plasmid_scores"], p["plasmid_lengths"])
            row["Plasmid_Length_Weighted_Score"] = (
                round(lw, 3) if not math.isnan(lw) else "NA"
            )
        else:
            row["Plasmid_Length_Weighted_Score"] = "NA"

        # Length_Weighted_Score for virus: length-weighted mean of virus_scores
        if v["virus_scores"]:
            lw_v = _length_weighted_mean(v["virus_scores"], v["virus_lengths"])
            row["Virus_Length_Weighted_Score"] = (
                round(lw_v, 3) if not math.isnan(lw_v) else "NA"
            )
        else:
            row["Virus_Length_Weighted_Score"] = "NA"

        # Plasmid_Signal_Uniformity: how uniform the plasmid signal is across contigs
        row["Plasmid_Signal_Uniformity"] = compute_plasmid_signal_uniformity(
            p["plasmid_scores"], p["plasmid_lengths"]
        )

        # Virus_Signal_Uniformity: how uniform the viral signal is across contigs
        row["Virus_Signal_Uniformity"] = compute_virus_signal_uniformity(
            v["virus_scores"],
            v["virus_lengths"],
            v["provirus_count"],
            v["provirus_max_score"],
        )

        # Mobility potential string
        row["Mobility_Potential"] = build_mobility_potential(
            row["Plasmid_Signal_Uniformity"],
            row["Virus_Signal_Uniformity"],
            v["provirus_count"],
            p["conjugation_types"],
        )

        # Bin_Type: classification from plasmid/virus signals and completeness
        row["Bin_Type"] = classify_bin_type(
            p["plasmid_scores"],
            v["virus_scores"],
            _safe_float(q.get("completeness", "0")),
            int(_safe_float(q.get("contig_count", "0"))),
        )

        # Use NA when geNomad plasmid file not present
        if p["file_found"]:
            row["Plasmid_Count"] = p["plasmid_count"]
            row["High_Conf_Plasmids"] = p["high_conf_plasmids"]
        else:
            row["Plasmid_Count"] = "NA"
            row["High_Conf_Plasmids"] = "NA"
        row["Conjugation_Genes"] = (
            ";".join(sorted(p["conjugation_types"])) if p["conjugation_types"] else "NA"
        )

        a = parse_amrfinderplus(input_dir, bin_name)
        # Use NA when AMRFinderPlus file not present
        if a["file_found"]:
            row["AMR_Gene_Count"] = a["amr_count"]
        else:
            row["AMR_Gene_Count"] = "NA"
        row["AMR_Classes"] = (
            ";".join(sorted(a["amr_classes"])) if a["amr_classes"] else "NA"
        )
        row["AMR_Genes"] = (
            ";".join(sorted(set(a["amr_genes"]))) if a["amr_genes"] else "NA"
        )

        results.append(row)

    return results


# Split table columns by bin type; each domain table gets only the columns
# relevant to that bin type so readers don't see NAs for irrelevant fields.

CHROMOSOME_COLS: List[str] = [
    "Name",
    "Bacterial_Confidence",
    "Taxonomy",
    "Completeness",
    "Contamination",
    "Closest_Ref_ANI",
    "Closest_Ref_AF",
    "Genome_Size",
    "Total_Contigs",
    "GC_Content",
    "N50",
    "Coding_Density",
    "AMR_Gene_Count",
    "AMR_Classes",
    "AMR_Genes",
]

PLASMID_COLS: List[str] = [
    "Name",
    "Bacterial_Confidence",
    "Taxonomy",
    "Completeness",
    "Contamination",
    "Closest_Ref_ANI",
    "Closest_Ref_AF",
    "Genome_Size",
    "Total_Contigs",
    "GC_Content",
    "N50",
    "Coding_Density",
    "Plasmid_Fraction",
    "Plasmid_Length_Weighted_Score",
    "Plasmid_Signal_Uniformity",
    "Plasmid_Count",
    "High_Conf_Plasmids",
    "Conjugation_Genes",
    "AMR_Gene_Count",
    "AMR_Classes",
    "AMR_Genes",
]

VIRUS_COLS: List[str] = [
    "Name",
    "Taxonomy",
    "Genome_Size",
    "Total_Contigs",
    "GC_Content",
    "N50",
    "Virus_Count",
    "High_Conf_Viruses",
    "Virus_Length_Weighted_Score",
    "Virus_Signal_Uniformity",
    "Provirus_Count",
    "Provirus_Fraction",
    "Mobility_Potential",
    "Virus_Taxonomy",
]

# Plasmid and virus tables rename the length-weighted score to "Length_Weighted_Score"
# so the column name matches across split tables.
VIRUS_COLS_OUTPUT_NAMES: Dict[str, str] = {
    "Virus_Length_Weighted_Score": "Length_Weighted_Score",
}

PLASMID_COLS_OUTPUT_NAMES: Dict[str, str] = {
    "Plasmid_Length_Weighted_Score": "Length_Weighted_Score",
}


# Filter and write small TSVs per bin type.


def filter_bins_by_type(
    results: List[Dict[str, Any]],
    target_type: str,
) -> List[Dict[str, Any]]:
    """Filter rows by Bin_Type."""
    return [row for row in results if row.get("Bin_Type") == target_type]


def _write_tsv(
    rows: List[Dict[str, Any]],
    columns: List[str],
    output_path: str,
) -> None:
    """Write a filtered TSV with only the specified columns."""
    with open(output_path, "w", newline="") as f:
        writer = csv.DictWriter(
            f, fieldnames=columns, delimiter="\t", extrasaction="ignore"
        )
        writer.writeheader()
        for row in rows:
            writer.writerow(row)


def write_split_tables(
    results: List[Dict[str, Any]],
    output_dir: str,
) -> None:
    """Write 3 domain-specific TSV files with only relevant columns."""
    out = Path(output_dir)

    # Chromosome MAGs keep (Chromosome_MAG)
    chrom_rows = filter_bins_by_type(results, "Chromosome_MAG")
    _write_tsv(chrom_rows, CHROMOSOME_COLS, str(out / "maggic-results-chromosome.tsv"))

    # Plasmid MAGs: remap Plasmid_Length_Weighted_Score to Length_Weighted_Score
    plasmid_rows = filter_bins_by_type(results, "Plasmid_MAG") + filter_bins_by_type(
        results, "Mixed_MAG"
    )
    plasmid_output = []
    for row in plasmid_rows:
        mapped_row = dict(row)
        for old_key, new_key in PLASMID_COLS_OUTPUT_NAMES.items():
            if old_key in mapped_row:
                mapped_row[new_key] = mapped_row.pop(old_key)
        plasmid_output.append(mapped_row)
    plasmid_out_cols = []
    for col in PLASMID_COLS:
        plasmid_out_cols.append(PLASMID_COLS_OUTPUT_NAMES.get(col, col))
    _write_tsv(
        plasmid_output, plasmid_out_cols, str(out / "maggic-results-plasmid.tsv")
    )

    # Virus MAGs: remap Virus_Length_Weighted_Score to Length_Weighted_Score
    # so the column name matches the plasmid table
    virus_rows = filter_bins_by_type(results, "Virus_MAG")
    virus_output = []
    for row in virus_rows:
        mapped_row = dict(row)
        for old_key, new_key in VIRUS_COLS_OUTPUT_NAMES.items():
            if old_key in mapped_row:
                mapped_row[new_key] = mapped_row.pop(old_key)
        virus_output.append(mapped_row)
    # Build output column list with remapped names
    virus_out_cols = []
    for col in VIRUS_COLS:
        virus_out_cols.append(VIRUS_COLS_OUTPUT_NAMES.get(col, col))
    _write_tsv(virus_output, virus_out_cols, str(out / "maggic-results-virus.tsv"))


# Compute summary statistics (datasum) across all bins for the MultiQC DATASUM cards.


def compute_datasum(results: List[Dict[str, Any]]) -> Dict[str, Any]:
    """Compute datasum counts from aggregated results."""
    datasum: Dict[str, Any] = {
        "total_bins": len(results),
        "bin_type_counts": {
            "Chromosome_MAG": 0,
            "Plasmid_MAG": 0,
            "Mixed_MAG": 0,
            "Virus_MAG": 0,
        },
        "confidence_counts": {
            "High": 0,
            "Medium": 0,
            "Low": 0,
        },
        "total_amr_genes": 0,
        "unique_amr_classes": set(),
        "top_taxa": {},
    }

    for row in results:
        # Bin type counts
        bt = row.get("Bin_Type", "Unknown")
        if bt in datasum["bin_type_counts"]:
            datasum["bin_type_counts"][bt] += 1

        # Confidence counts
        conf = row.get("Bacterial_Confidence", "Unknown")
        if conf in datasum["confidence_counts"]:
            datasum["confidence_counts"][conf] += 1

        # AMR totals
        datasum["total_amr_genes"] += _safe_float(row.get("AMR_Gene_Count", 0))
        amr_classes = row.get("AMR_Classes", "NA")
        if amr_classes and amr_classes != "NA":
            for cls in amr_classes.split(";"):
                cls = cls.strip()
                if cls:
                    datasum["unique_amr_classes"].add(cls)

        # Top taxa at finest available rank, cascading down from species
        taxonomy = row.get("Taxonomy", "NA")
        if taxonomy and taxonomy != "NA":
            parts = taxonomy.split(";")
            # GTDB-Tk: d__;p__;c__;o__;f__;g__;s__ (indices 0-6)
            taxon = "Unclassified"
            for idx in range(6, 0, -1):
                if len(parts) > idx and parts[idx].strip():
                    taxon = parts[idx]
                    break
            datasum["top_taxa"][taxon] = datasum["top_taxa"].get(taxon, 0) + 1

    # Convert set to sorted list for JSON serialization
    datasum["unique_amr_classes"] = sorted(datasum["unique_amr_classes"])

    # Sort top_taxa by count descending, keep top 10
    datasum["top_taxa"] = dict(
        sorted(datasum["top_taxa"].items(), key=lambda x: x[1], reverse=True)[:10]
    )

    return datasum


def write_datasum_json(
    datasum: Dict[str, Any],
    output_file: str,
) -> None:
    """Write datasum dictionary as JSON."""
    with open(output_file, "w") as f:
        json.dump(datasum, f, indent=2, default=str)


# Write final aggregated results to TSV.


def write_output(
    results: List[Dict[str, Any]],
    output_path: str,
    warnings: Optional[List[str]] = None,
) -> None:
    """Write aggregated results to TSV file."""
    with open(output_path, "w", newline="") as f:
        if not results and warnings:
            for warning in warnings:
                f.write(f"# {warning}\n")

        writer = csv.DictWriter(f, fieldnames=HEADER, delimiter="\t")
        writer.writeheader()
        for row in results:
            writer.writerow(row)


def main() -> None:
    """Entry point."""
    args = parse_args()
    input_dir = args.input_dir

    if not os.path.isdir(input_dir):
        print(
            f"MAGGIC: Error: Input directory '{input_dir}' does not exist.",
            file=sys.stderr,
        )
        sys.exit(1)

    warnings: List[str] = []
    results = aggregate_all(
        input_dir,
        args.min_virus_score,
        args.min_plasmid_score,
        args.output,
        args.max_fdr,
        high_comp=args.high_comp,
        high_contam=args.high_contam,
        high_ani=args.high_ani,
        high_af=args.high_af,
        med_comp=args.med_comp,
        med_contam=args.med_contam,
        med_ani=args.med_ani,
        med_af=args.med_af,
    )

    if not results:
        warnings.append("MAGGIC: Warning: No bin results found in input directory.")
        write_output([], args.output, warnings)
        sys.exit(0)

    for row in results:
        if row["Taxonomy"] == "NA":
            print(
                f"MAGGIC: Warning: No GTDB-Tk taxonomy for bin {row['Name']}",
                file=sys.stderr,
            )
        if row["AMR_Gene_Count"] == 0 and row["AMR_Classes"] == "NA":
            print(
                f"MAGGIC: Warning: No AMRFinderPlus results for bin {row['Name']}",
                file=sys.stderr,
            )

    write_output(results, args.output)

    # Determine output directory from the output file path
    output_dir = os.path.dirname(args.output) or "."

    # Write split domain tables
    write_split_tables(results, output_dir)
    print(f"MAGGIC: Wrote split domain tables to {output_dir}", file=sys.stderr)

    # Write datasum JSON
    datasum = compute_datasum(results)
    datasum_path = os.path.join(output_dir, "maggic-results-datasum.json")
    write_datasum_json(datasum, datasum_path)
    print(f"MAGGIC: Wrote DATASUM JSON to {datasum_path}", file=sys.stderr)

    coverm_results = discover_coverm_abn_results(input_dir, args.cov_merged)
    if coverm_results:
        print(
            f"MAGGIC: Merged {len(coverm_results)} bins from CoverM files "
            f"into {args.cov_merged}",
            file=sys.stderr,
        )
    else:
        print(
            "MAGGIC: Warning: No CoverM files found or bins inconsistent.",
            file=sys.stderr,
        )


if __name__ == "__main__":
    main()
