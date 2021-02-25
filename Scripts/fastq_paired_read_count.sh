# This script reads both compressed and uncompressed fastq files
# It creates a tabulated file with samplename, number of reads and total number of bases
# use with parallel --xapply -j 1 "fastq_stats.sh {1} {2}" ::: *_1.fastq* ::: *_2.fastq* or the qsub compatible batch_fastq_paired_read_count.sh
Sample="$(echo -n $1 | rev | cut -f 1 -d '/' | rev | sed 's/_1.*//g')"
echo -n "$Sample	" >> fastq_stats.tab
zcat --force "$1" "$2" | awk '{OFS="\t"} NR%4==2{c++; l+=length($0)} END{print "Number of reads	"c,"Total number of bases	"l}' >> fastq_stats.tab
