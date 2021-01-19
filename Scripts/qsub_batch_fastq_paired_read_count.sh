#!/bin/sh
### Note: No commands may be executed until after the #PBS lines
### Account information
#PBS -W group_list=cu_10108 -A cu_10108
### Job name (comment out the next line to get the name of the script used as the job name)
#PBS -N fastq_count
### Output files (comment out the next 2 lines to get the job name used instead)
#PBS -e $PBS_JOBID.fastq_count.stderr
#PBS -o $PBS_JOBID.fastq_count.stdout
### Only send mail when job is aborted or terminates abnormally
#PBS -m n
### Number of nodes
#PBS -l nodes=1:ppn=2:thinnode
### Requesting time - format is <days>:<hours>:<minutes>:<seconds> (here, 24 hours)
#PBS -l walltime=00:2:00:00
# V1.00 Written by Gisle Vestergaard (gislevestergaard@gmail.com)
# Go to the directory from where the job was submitted (initial directory is $HOME)
echo Working directory is "$PBS_O_WORKDIR"
cd "$PBS_O_WORKDIR"

 
### Here follows the user commands:
# This script is made to run the script "fastq_paired_read_count" on larger scale. It reads both compressed and uncompressed fastq files
# It creates a tabulated file with samplename, number of reads and total number of bases
[ $# != 2 ] && { echo "Usage: qsub -F '<R1 read list FILE> <R2 read list FILE>' biopythonpieces_batch_fastq_paired_read_count"; exit 1; }
R1=$1
R2=$2
/home/projects/cu_10108/data/Bin/parallel --xapply -j 1 "/home/projects/cu_10108/data/Scripts/biopythonpieces_fastq_paired_read_count.sh {1} {2}" :::: "$R1" :::: "$R2"
