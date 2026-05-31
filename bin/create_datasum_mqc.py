#!/usr/bin/env python3
#
# Kranti Konganti
#
# 05/30/2026
# (C) HFP, FDA
#

import argparse
import json
import sys
from pathlib import Path

import yaml

# Material Design color palette for stat cards.
CARD_COLORS = {
    "total": ("#3f51b5", "indigo"),
    "chrom": ("#00bcd4", "cyan"),
    "plasmid": ("#ff9800", "orange"),
    "mixed": ("#795548", "brown"),
    "virus": ("#e91e63", "pink"),
    "high": ("#4caf50", "green"),
    "medium": ("#ffc107", "amber"),
    "low": ("#f44336", "red"),
    "amr": ("#9c27b0", "purple"),
}


def parse_args() -> argparse.Namespace:
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Convert datasum JSON into MultiQC custom_content YAML with DATASUM cards."
    )
    parser.add_argument("datasum_json", help="Path to maggic-results-datasum.json")
    return parser.parse_args()


def _datasum_html(datasum: dict) -> str:
    """Build Material Design-inspired HTML summary cards.

    Uses card-based layout with gradient backgrounds, shadow, and
    icon-like size indicators instead of plain Bootstrap badges.
    """
    bt = datasum.get("bin_type_counts", {})
    chrom = bt.get("Chromosome_MAG", 0)
    plasmid = bt.get("Plasmid_MAG", 0)
    mixed = bt.get("Mixed_MAG", 0)
    virus = bt.get("Virus_MAG", 0)
    total = datasum.get("total_bins", 0)

    cc = datasum.get("confidence_counts", {})
    high = cc.get("High", 0)
    med = cc.get("Medium", 0)
    low = cc.get("Low", 0)

    amr_genes = datasum.get("total_amr_genes", 0)
    amr_classes = datasum.get("unique_amr_classes", [])

    top_taxa = datasum.get("top_taxa", {})

    html_parts = [
        "<style>",
        ".maggic-card {",
        "  display: flex;",
        "  flex-wrap: wrap;",
        "  gap: 12px;",
        "  padding: 12px 0;",
        "}",
        ".maggic-stat-card {",
        "  flex: 1 1 160px;",
        "  min-width: 130px;",
        "  max-width: 320px;",
        "  border-radius: 8px;",
        "  padding: 16px 18px;",
        "  color: #fff;",
        "  box-shadow: 0 2px 8px rgba(0,0,0,0.14), 0 1px 3px rgba(0,0,0,0.12);",
        "  transition: box-shadow 0.2s ease, transform 0.2s ease;",
        "}",
        ".maggic-stat-card:hover {",
        "  box-shadow: 0 6px 16px rgba(0,0,0,0.18), 0 2px 4px rgba(0,0,0,0.12);",
        "  transform: translateY(-2px);",
        "}",
        ".maggic-stat-value {",
        "  font-size: 32px;",
        "  font-weight: 700;",
        "  line-height: 1.2;",
        "}",
        ".maggic-stat-label {",
        "  font-size: 12px;",
        "  font-weight: 500;",
        "  opacity: 0.92;",
        "  text-transform: uppercase;",
        "  letter-spacing: 0.3px;",
        "  white-space: nowrap;",
        "  overflow: hidden;",
        "  text-overflow: ellipsis;",
        "  min-width: 0;",
        "}",
        ".maggic-section-title {",
        "  font-size: 16px;",
        "  font-weight: 600;",
        "  margin: 20px 0 8px 0;",
        "  color: #333;",
        "  border-bottom: 2px solid #e0e0e0;",
        "  padding-bottom: 4px;",
        "}",
        "</style>",
        '<div class="maggic-datasum">',
        # Bin Type Cards
        '<div class="maggic-section-title">Bin Classification</div>',
        '<div class="maggic-card">',
        _card(total, "Total Bins", CARD_COLORS["total"][0]),
        _card(chrom, "Chromosome MAGs", CARD_COLORS["chrom"][0]),
        _card(plasmid, "Plasmid MAGs", CARD_COLORS["plasmid"][0]),
        _card(mixed, "Mixed MAGs", CARD_COLORS["mixed"][0]),
        _card(virus, "Virus MAGs", CARD_COLORS["virus"][0]),
        "</div>",
        # Confidence Cards
        '<div class="maggic-section-title">Bacterial Confidence</div>',
        '<div class="maggic-card">',
        _card(high, "High Confidence", CARD_COLORS["high"][0]),
        _card(med, "Medium Confidence", CARD_COLORS["medium"][0]),
        _card(low, "Low Confidence", CARD_COLORS["low"][0]),
        "</div>",
        # AMR Cards
        '<div class="maggic-section-title">Antimicrobial Resistance</div>',
        '<div class="maggic-card">',
        _card(amr_genes, "AMR Genes Detected", CARD_COLORS["amr"][0]),
        _card(len(amr_classes), "AMR Classes", CARD_COLORS["amr"][0]),
        "</div>",
    ]

    # Top Taxa
    if top_taxa:
        html_parts.append('<div class="maggic-section-title">Top Taxa</div>')
        html_parts.append(
            '<div class="maggic-card" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 12px;">'
        )
        for taxon, count in list(top_taxa.items())[:10]:
            # Alternate colors across taxa using a hash-based approach
            hue = hash(taxon) % 360
            color = f"hsl({hue}, 60%, 35%)"
            html_parts.append(_card(count, taxon, color))
        html_parts.append("</div>")

    html_parts.append("</div>")
    return "\n".join(html_parts)


def _card(value: int, label: str, color: str) -> str:
    """Return a Material Design-style stat card string."""
    escaped = label.replace(" ", "&nbsp;")
    return (
        f'<div class="maggic-stat-card" style="background:{color};">'
        f'<div class="maggic-stat-value">{value}</div>'
        f'<div class="maggic-stat-label" title="{label}">{escaped}</div>'
        f"</div>"
    )


def main() -> None:
    """Entry point."""
    args = parse_args()
    datasum_file = Path(args.datasum_json)

    if not datasum_file.exists():
        print(f"ERROR: DATASUM file not found: {datasum_file}", file=sys.stderr)
        sys.exit(1)

    with open(datasum_file, "r") as f:
        datasum = json.load(f)

    html = _datasum_html(datasum)

    mqc_yaml = {
        "id": "MAGGICRESULTS_DATASUM",
        "section_name": "MAGGIC Data Summary",
        "section_href": "https://github.com/CFSAN-Biostatistics/maggic",
        "plot_type": "html",
        "description": "Data summary for all detected bins.",
        "data": html,
    }

    out_file = datasum_file.parent / "maggic_results_datasum_mqc.yml"
    with open(out_file, "w") as f:
        yaml.dump(mqc_yaml, f, default_flow_style=False)

    print(f"Wrote DATASUM MultiQC YAML to {out_file}", file=sys.stderr)


if __name__ == "__main__":
    main()
