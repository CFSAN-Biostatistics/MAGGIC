#!/usr/bin/env python3
#
# Kranti Konganti
#
# 05/15/2026
# (C) HFP, FDA
#

import argparse
import csv
import os
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional, Set, Tuple


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
    "Completeness",
    "Contamination",
    "Genome_Size",
    "Total_Contigs",
    "GC_Content",
    "N50",
    "Coding_Density",
    "Taxonomy",
    "Closest_Ref_ANI",
    "Closest_Ref_AF",
    "Bacterial_Confidence",
    "Virus_Count",
    "High_Conf_Viruses",
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
    excluded_files: Set[str] = {"ALL_REFINED_BINS_QUALITY_REPORT.tsv"}
    if output_file:
        excluded_files.add(Path(output_file).name)
    excluded_files.add("maggic-globalabundance.tsv")

    for fpath in input_path.iterdir():
        name = fpath.name

        if name in excluded_files:
            continue

        # geNomad virus files: <bin>_virus_summary.tsv
        if name.endswith("_virus_summary.tsv"):
            bin_name = name.replace("_virus_summary.tsv", "")
            bins.add(bin_name)

        # geNomad plasmid files: <bin>_plasmid_summary.tsv
        elif name.endswith("_plasmid_summary.tsv"):
            bin_name = name.replace("_plasmid_summary.tsv", "")
            bins.add(bin_name)

        # AMRFinderPlus: <bin>.tsv (but not summary files, not CoverM files)
        elif name.endswith(".tsv") and "_summary" not in name and not name.endswith(".coverm.tsv"):
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
                        result["closest_ani"] = (
                            ani if ani and ani.strip() else "NA"
                        )
                        result["closest_af"] = (
                            af if af and af.strip() else "NA"
                        )
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
        "virus_count": 0,
        "high_conf_viruses": 0,
        "virus_taxonomies": set(),
    }

    virus_file = Path(input_dir) / f"{bin_name}_virus_summary.tsv"
    if not virus_file.exists():
        return result

    try:
        with open(virus_file, "r") as f:
            reader = csv.DictReader(f, delimiter="\t")
            for row in reader:
                result["virus_count"] += 1

                taxonomy = row.get("taxonomy", "NA")
                if taxonomy and taxonomy != "NA" and taxonomy.strip():
                    result["virus_taxonomies"].add(taxonomy.strip())

                score = row.get("virus_score", "0")
                fdr = row.get("fdr", "NA")
                try:
                    score_val = float(score)
                    if fdr and fdr != "NA" and fdr.strip():
                        fdr_val = float(fdr)
                        if (
                            score_val >= min_virus_score
                            and fdr_val <= max_fdr
                        ):
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
        "plasmid_count": 0,
        "high_conf_plasmids": 0,
        "conjugation_types": set(),
    }

    plasmid_file = Path(input_dir) / f"{bin_name}_plasmid_summary.tsv"
    if not plasmid_file.exists():
        return result

    try:
        with open(plasmid_file, "r") as f:
            reader = csv.DictReader(f, delimiter="\t")
            for row in reader:
                result["plasmid_count"] += 1

                score = row.get("plasmid_score", "0")
                fdr = row.get("fdr", "NA")
                try:
                    score_val = float(score)
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


def parse_amrfinderplus(
    input_dir: str, bin_name: str
) -> Dict[str, Any]:
    """Parse AMRFinderPlus results for a single bin."""
    result: Dict[str, Any] = {
        "amr_count": 0,
        "amr_classes": set(),
        "amr_genes": [],
    }

    amr_file = Path(input_dir) / f"{bin_name}.tsv"
    if not amr_file.exists():
        return result

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
                    if (
                        amr_class
                        and amr_class != "NA"
                        and amr_class.strip()
                    ):
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

        v = parse_genomad_virus(
            input_dir, bin_name, min_virus_score, max_fdr_decimal
        )
        row["Virus_Count"] = v["virus_count"]
        row["High_Conf_Viruses"] = v["high_conf_viruses"]
        row["Virus_Taxonomy"] = (
            ";".join(sorted(v["virus_taxonomies"]))
            if v["virus_taxonomies"]
            else "NA"
        )

        p = parse_genomad_plasmid(
            input_dir, bin_name, min_plasmid_score, max_fdr_decimal
        )
        row["Plasmid_Count"] = p["plasmid_count"]
        row["High_Conf_Plasmids"] = p["high_conf_plasmids"]
        row["Conjugation_Genes"] = (
            ";".join(sorted(p["conjugation_types"]))
            if p["conjugation_types"]
            else "NA"
        )

        a = parse_amrfinderplus(input_dir, bin_name)
        row["AMR_Gene_Count"] = a["amr_count"]
        row["AMR_Classes"] = (
            ";".join(sorted(a["amr_classes"]))
            if a["amr_classes"]
            else "NA"
        )
        row["AMR_Genes"] = (
            ";".join(sorted(set(a["amr_genes"])))
            if a["amr_genes"]
            else "NA"
        )

        results.append(row)

    return results


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
        warnings.append(
            "MAGGIC: Warning: No bin results found in input directory."
        )
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