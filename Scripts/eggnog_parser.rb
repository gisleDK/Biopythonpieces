#!/usr/bin/env ruby
# Made using Ruby 2.6.6p146
# V1.00 Written by Gisle Vestergaard (gislevestergaard@gmail.com)
# This takes a directory with eggnog-mapper output files and 
# a tabulated output

require 'pp'
require 'optparse'

ARGV << '-h' if ARGV.empty?

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)} [options]"

  opts.on('-h', '--help', 'Display this screen') do
    $stderr.puts opts
    exit
  end

  opts.on('-i', '--in_dir <directory>', String, 'Input directory containing .cog files') do |o|
    options[:input_dir] = o
  end

  opts.on('-o', '--output_seed_file <file>', String, 'output eggnog seed file (default is cog.collapse)') do |o|
    options[:cog_file] = o
  end

  opts.on('-c', '--output_cogcat_file <file>', String, 'output cog category file (default is cogcat.collapse)') do |o|
    options[:cat_file] = o
  end

  	opts.on('-u', '--unique', "if r1 hit == r2 hit count them as 1") do |o|
    options[:uniq] = o
  end

end.parse!

options[:seed_file] ||= 'seed.collapse'
options[:cat_file] ||= 'cogcat.collapse'
files         = []
counts        = {}
seeds         = []
cogcats       = []
cogcat_counts = Hash.new(0)
samplenames   = []

# Make an array of all input samples
Dir.glob(options[:input_dir] + '/*emapper.annotations') do |item|
  files << item
end

# Use Bash to sum counts for each sample of seeds and cog categories
files.each do |file|
  count       = []
  seedhash    = {}
  cogcathash  = {}
  cogcatcount = {}
  if options[:uniq]
  	sumseeds    = `cat #{file} | grep -v '^#' | cut -f 1,2 | sort -u | cut -f 2 | sort | uniq -c`
  	sumcogcats  = `cat #{file} | grep -v '^#' | cut -f 1,12 |sort -u | cut -f 2 | sed -e $'s/, /\\\n/g' | sed '/^$/d' | sort | uniq -c`
  else
  	sumseeds    = `cat #{file} | grep -v '^#' | cut -f 2 | sort | uniq -c`
  	sumcogcats  = `cat #{file} | grep -v '^#' | cut -f 12 | sed '/^$/d' | sed -e $'s/, /\\\n/g' | sort | uniq -c`
end
  samplename  = file.split('/').last.split('.').first
  samplenames << samplename
  sumseeds.each_line do |line|
    line.chomp!
    fields = line.split("\t")
    count = fields[0].split(' ')[0]
    seeds << fields[0].split(' ')[1]
    seed = fields[0].split(' ')[1]
    seedhash[seed] = count
    counts[samplename] = seedhash
  end
  sumcogcats.each_line do |line|
    line.chomp!
    fields = line.split("\t")
    count = fields[0].split(' ')[0]
    cogcats << fields[0].split(' ')[1].split('')
    cogcat = fields[0].split(' ')[1].split('')
    cogcat.each do
      cogcathash[cogcat] = count
    end
  end
  cogcats.flatten.uniq.each do |uniq|
    cogcathash.each do |key, value|
      value.to_i
      key.each do |k|
        if k == uniq
          if cogcatcount.key?(uniq)
            cogcatcount[uniq] += value.to_i
          else
            cogcatcount[uniq] = value.to_i
          end
        end
      end
    end
  end
  cogcat_counts[samplename] = cogcatcount
end

seeds.uniq!
cogcats.flatten!.uniq!

# Write seed summary
File.open(options[:seed_file], 'w') do |file|
  file.print(seeds.join("\t"), "\n")
  counts.each do |sample, data|
    file.print(sample, "\t")
    seeds.each do |seed|
      if data.key?(seed)
        file.print(data[seed], "\t")
      else
        file.print("0\t")
      end
    end
    file.print("\n")
  end
end
# Write cog category summary

File.open(options[:cat_file], 'w') do |file|
  file.print(cogcats.join("\t"), "\n")
  cogcat_counts.each do |sample, data|
    file.print(sample, "\t")
    cogcats.each do |cog|
      if data.key?(cog)
        file.print(data[cog], "\t")
      else
        file.print("0\t")
      end
    end
    file.print("\n")
  end
end
