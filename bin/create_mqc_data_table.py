#!/usr/bin/env python3

import argparse
import os
import sys
from textwrap import dedent

import yaml

# bgcols used for value-to-color mapping, following MultiQC native style.
# MultiQC uses headers dict with bgcols key for cell coloring in data tables.

# Confidence color palette matches Bootstrap/MultiQC conventions.
CONFIDENCE_COLORS = {
    "High": "#28a745",
    "Medium": "#ffc107",
    "Low": "#dc3545",
}


def parse_args() -> argparse.Namespace:
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Generate HTML DataTable for MultiQC from a TSV file."
    )
    parser.add_argument(
        "table_name",
        help="Base name for the table (used for output filenames and DataTable ID)",
    )
    parser.add_argument(
        "--description",
        "-d",
        default="The results table shown here is a collection from all samples.",
        help="Description text for the MultiQC section",
    )
    parser.add_argument(
        "--hide-cols",
        "-H",
        default="",
        help="Comma-separated list of column indices (0-based) to hide by default in DataTables",
    )
    parser.add_argument(
        "--color-col",
        "-C",
        default="",
        help="Column name(s) to color-code, comma-separated (e.g., Bacterial_Confidence,Plasmid_Signal_Uniformity)",
    )
    parser.add_argument(
        "--color-values",
        "-V",
        default="",
        help="bgcols-style color mapping as colname:value1:color1;colname:value2:color2. Each mapping starts with a column prefix (e.g., Bacterial_Confidence:High:#28a745;Bacterial_Confidence:Medium:#ffc107;Plasmid_Signal_Uniformity:High:#28a745)",
    )
    return parser.parse_args()


def main() -> None:
    """
    Takes a tab-delimited text file with a mandatory header
    column and generates an HTML DataTable for MultiQC custom_content.

    Uses MultiQC native bgcols pattern for cell coloring instead of
    external cellcolors.yml files, as MultiQC v1.35 does not recognize
    cellcolors.yml as a built-in feature.
    """
    args = parse_args()

    table_sum_on = args.table_name
    table_sum_on_file = table_sum_on + ".tblsum.txt"
    description = args.description

    # Parse color columns and per-column bgcols mappings.
    # Supports multiple columns when the caller needs to color more than
    # one column in the same table (e.g., Bacterial_Confidence AND
    # Plasmid_Signal_Uniformity in the plasmid table).
    color_cols = [c.strip() for c in args.color_col.split(",") if c.strip()]
    color_maps = {}
    if args.color_values and color_cols:
        parts = args.color_values.split(";")
        for part in parts:
            segments = part.strip().split(":")
            if len(segments) >= 3 and segments[0].strip() in color_cols:
                col_name = segments[0].strip()
                value = ":".join(segments[1:-1]).strip()
                color = segments[-1].strip()
                color_maps.setdefault(col_name, {})[value] = color

    # Parse hidden column indices
    hidden_cols = []
    if args.hide_cols:
        try:
            hidden_cols = [
                int(i.strip()) for i in args.hide_cols.split(",") if i.strip()
            ]
        except ValueError:
            print(
                f"WARN: Invalid --hide-cols value '{args.hide_cols}', ignoring.",
                file=sys.stderr,
            )

    if not (
        os.path.exists(table_sum_on_file) and os.path.getsize(table_sum_on_file) > 0
    ):
        exit(0)

    with open(table_sum_on_file, "r") as tbl:
        header = tbl.readline()
        header_cols = header.strip().split("\t")

        # Build columnDefs for hidden columns
        column_defs = []
        for col_idx in hidden_cols:
            if 0 <= col_idx < len(header_cols):
                column_defs.append(dedent(f"""{{
                                targets: {col_idx},
                                visible: false
                            }}"""))

        # Build DataTable init options - collect them
        dt_options = []
        dt_options.append("scrollX: true")
        dt_options.append("fixedColumns: true")
        dt_options.append("dom: 'Bfrtip'")
        dt_options.append(dedent("""buttons: [
                                'copy',
                                {
                                    extend: 'print',
                                    title: 'CPIPES: MultiQC Report: {table_name}'
                                },
                                {
                                    extend: 'excel',
                                    filename: '{table_name}_results',
                                },
                                {
                                    extend: 'csv',
                                    filename: '{table_name}_results',
                                }
                            ]""".replace("{table_name}", table_sum_on)))
        if column_defs:
            dt_options.append("columnDefs: [" + ",\n".join(column_defs) + "]")

        # Join dt_options with proper formatting (Python 3.12+ allows backslashes in f-strings)
        dt_joined = ",\n                            ".join(dt_options)

        html = []
        html.append(f"""<script type="text/javascript">
                    $(document).ready(function () {{
                        $('#cpipes-process-custom-res-{table_sum_on}').DataTable({{
                            {dt_joined}
                        }});
                    }});
                </script>""")
        html.append(f"""<div class="table-responsive">
                <style>
                #cpipes-process-custom-res-{table_sum_on} tr:nth-child(even) {{
                    background-color: #f2f2f2;
                }}
                #cpipes-process-custom-res-{table_sum_on} td.shrunk {{
                    padding: 2px 6px;
                    text-align: right;
                    white-space: nowrap;
                }}
                #cpipes-process-custom-res-{table_sum_on} td.color-cell {{
                    font-weight: bold;
                    padding: 4px 10px;
                    border-radius: 4px;
                    margin: 1px 2px;
                }}
                </style>
                <table class="table" style="width:100%" id="cpipes-process-custom-res-{table_sum_on}">
                <thead>
                <tr>""")

        # Add style class hints for numeric columns
        numeric_hint_cols = {
            "Completeness",
            "Contamination",
            "Closest_Ref_ANI",
            "Closest_Ref_AF",
        }

        for i, header_col in enumerate(header_cols):
            col_class = ""
            if header_col in numeric_hint_cols:
                col_class = ' class="shrunk"'
            html.append(dedent(f"""
                        <th{col_class}>{header_col}</th>"""))

        html.append("""
                </tr>
                </thead>
                <tbody>""")

        for row in tbl:
            html.append("<tr>\n")
            data_cols = row.strip().split("\t")
            if len(header_cols) != len(data_cols):
                print(
                    f"\nWARN: Number of header columns ({len(header_cols)}) and data "
                    f"columns ({len(data_cols)}) are not equal!\nWill append empty columns!\n"
                )
                if len(header_cols) > len(data_cols):
                    data_cols += (len(header_cols) - len(data_cols)) * [" "]
                else:
                    header_cols += (len(data_cols) - len(header_cols)) * [" "]

            # First column gets <samp> wrapper for bin name
            html.append(dedent(f"""
                        <td><samp>{data_cols[0]}</samp></td>
                    """))

            for j, data_col in enumerate(data_cols[1:], start=1):
                header_name = header_cols[j] if j < len(header_cols) else ""
                numeric_class = (
                    ' class="shrunk"' if header_name in numeric_hint_cols else ""
                )

                # Apply bgcols-style coloring when value matches a color key.
                # Checks all configured color columns so multiple columns
                # in the same table can be colored independently.
                if header_name in color_maps and data_col in color_maps[header_name]:
                    html.append(
                        dedent(
                            f"""<td class="color-cell" style="background-color: {color_maps[header_name][data_col]}">{data_col}</td>
                        """
                        )
                    )
                    continue

                # Numeric hint for data columns
                html.append(dedent(f"""<td{numeric_class}>{data_col}</td>
                    """))
            html.append("</tr>\n")
        html.append("</tbody>\n")
        html.append("</table>\n")
        html.append("</div>\n")

        mqc_yaml = {
            "id": f"{table_sum_on.upper()}_collated_table",
            "section_name": f"{table_sum_on.upper()}",
            "section_href": f"https://github.com/CFSAN-Biostatistics/maggic",
            "plot_type": "html",
            "description": f"{description}",
            "data": ("").join(html),
        }

        with open(f"{table_sum_on.lower()}_mqc.yml", "w") as html_mqc:
            yaml.dump(mqc_yaml, html_mqc, default_flow_style=False)


if __name__ == "__main__":
    main()
