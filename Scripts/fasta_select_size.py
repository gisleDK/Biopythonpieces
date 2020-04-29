#!/usr/bin/env python
# Made for Python 3.7

import argparse
import Bio
from Bio import SeqIO

parser = argparse.ArgumentParser(description='Select fasta entries by lenght')
parser.add_argument("-f", "--file", required = True, 
					help="Input fasta file")
parser.add_argument("-L", "--large",  
					help="Select larger or equal to this number of basepairs", type=int)
parser.add_argument("-S", "--small",  
					help="Select smaller or equal to this number of basepairs", type=int)
parser.add_argument("-o", "--output", required = True, 
					help="Output fasta file")
parser.parse_args()
args = parser.parse_args()

if args.large is None and args.small is None:
	parser.print_help()

if args.large:
	long_sequences = []
	with open(args.file, "r") as handle:
		for record in SeqIO.parse(handle, "fasta") :
			if len(record) >= args.large:
				long_sequences.append(record)				
	SeqIO.write(long_sequences, args.output, "fasta")
if args.small:
	short_sequences = []
	with open(args.file, "r") as handle:
		for record in SeqIO.parse(handle, "fasta") :
			if len(record) <= args.small:
				short_sequences.append(record)
	SeqIO.write(short_sequences, args.output, "fasta")
