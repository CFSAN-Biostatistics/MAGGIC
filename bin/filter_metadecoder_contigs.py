#!/usr/bin/env python3
#
# Kranti Konganti
#
# 05/21/2026
# (C) HFP, FDA
#

import argparse
from datetime import datetime


def log(msg):
    print(f"{datetime.now().strftime('%Y-%m-%d %H:%M:%S')} MAGGIC::METADECODER::filter_metadecoder_contigs.py -> {msg}")


def main():
    parser = argparse.ArgumentParser(description='Filter FASTA file to include only contigs >= min_length')
    parser.add_argument('--fasta', required=True, help='Input FASTA file')
    parser.add_argument('--min_length', type=int, required=True, help='Minimum contig length threshold')
    parser.add_argument('--prefix', required=True, help='Output file prefix')
    args = parser.parse_args()

    # Parse FASTA file
    log(f"Loading FASTA file: {args.fasta}")
    contigs = {}
    current_contig = None
    current_sequence = []
    with open(args.fasta, 'r') as f:
        for line in f:
            line = line.rstrip('\n')
            if line.startswith('>'):
                if current_contig is not None:
                    contigs[current_contig] = ''.join(current_sequence)
                current_contig = line.split(' ')[0][1:]
                current_sequence = []
            else:
                current_sequence.append(line)
        if current_contig is not None:
            contigs[current_contig] = ''.join(current_sequence)

    total = len(contigs)
    log(f"Total contigs: {total}")

    # Filter contigs by minimum length
    filtered = {k: v for k, v in contigs.items() if len(v) >= args.min_length}
    kept = len(filtered)
    log(f"Contigs >= {args.min_length}bp: {kept}")
    log(f"Filtered out: {total - kept} contigs < {args.min_length}bp")

    # Write filtered FASTA file
    output_file = f"{args.prefix}.filtered.fa"
    with open(output_file, 'w') as f:
        for contig_id, sequence in filtered.items():
            f.write(f">{contig_id}\n")
            for i in range(0, len(sequence), 80):
                f.write(f"{sequence[i:i+80]}\n")

    log(f"Output written to: {output_file}")


if __name__ == '__main__':
    main()