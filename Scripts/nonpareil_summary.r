## ---------------------------
##
## Script name: nonpareil_summary.r
##
## Purpose of script: Create a xy file summarizing the Nonpareil analysis of all samples provided
##
## Part of Biopythonpieces
##
## Author: Gisle Vestergaard
##
## Date Created: 2020-06-01
##
## Email: gisves@dtu.dk
##
## ---------------------------
## load up the packages we will need:  (uncomment as required)
require(Nonpareil)
## ---------------------------
## setwd("?")
## This reads files generated by fasta_seqlen.py or any other tabulated file
system("echo 'File' > allnpos.list; ls | grep '.npo$' >> allnpos.list")
samples <- read.table('allnpos.list', sep='\t', h=T);
attach(samples);
np <- Nonpareil.set(File, plot = FALSE);
np_indices <- summary(np);
write.csv(np_indices, "nonpareil_indices.csv");
system("rm allnpos.list")