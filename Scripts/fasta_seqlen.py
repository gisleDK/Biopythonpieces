#!/usr/bin/env python
# Made for Python 3.7

import argparse
import Bio
from Bio import SeqIO

parser = argparse.ArgumentParser(description='Prints fasta entries lenght')
parser.add_argument("-f", "--file", required = True, 
					help="Input fasta file")
parser.parse_args()
args = parser.parse_args()

with open(args.file, "r") as handle:
	for record in SeqIO.parse(handle, "fasta") :
		print(record.id, len(record))
