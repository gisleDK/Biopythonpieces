## ---------------------------
##
## Script name: plot_fasta_lengths
##
## Purpose of script: Plot length of fasta entries. Mostly for analyzing assembly
##
## Part of Biopythonpieces
##
## Author: Gisle Vestergaard
##
## Date Created: 2020-04-24
##
## Email: gisves@dtu.dk
##
## ---------------------------
## load up the packages we will need:  (uncomment as required)
require(tidyverse)
## ---------------------------
setwd("~/Work/R/Scripts/Contig lengths")
## This reads files generated by fasta_seqlen.py or any other tabulated file
tabl <- read_delim("all_assemblies_seqlen.list", " ", col_names = c("Contig", "Length"))
ggplot(data = tabl) + geom_histogram(mapping = aes(x = Length), binwidth = 50000) + scale_y_log10()
ggsave("seqlens.pdf", width = 20, height = 20, units = "cm", dpi = 300)
## Focus on short contigs
ggplot(data = filter(tabl, Length < 5000)) + geom_histogram(mapping = aes(x = Length), binwidth = 100)
ggsave("seqlens_lessthan5000.pdf", width = 20, height = 20, units = "cm", dpi = 300)
