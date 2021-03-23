#!/home/incerta/Metagenomics/bin/Programs/Miniconda/bin/ruby
# Written using Ruby 2.7.2p137
# V1.00 Written by Gisle Vestergaard (gislevestergaard@gmail.com)
# Uses <sample>.emapper.annotations output from eggnog-mapper and
# summarizes the amount of reads matching either cog, cog category
# or KEGG ortholog. There is also an option of counting r1 and r2
# hits as one if they are the same.

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

  opts.on('-i', '--in_dir <directory>', String, 'Input directory containing eggnog-mapper output files') do |o|
    options[:input_dir] = o
  end

  opts.on('-o', '--output_seed_file <file>', String, 'output eggnog seed file (default is cog.collapse)') do |o|
    options[:cog_file] = o
  end

  opts.on('-c', '--output_cogcat_file <file>', String, 'output cog category file (default is cogcat.collapse)') do |o|
    options[:cat_file] = o
  end

    opts.on('-k', '--output_kegg_file <file>', String, 'output kegg orthology file (default is kegg.collapse)') do |o|
    options[:kegg_file] = o
  end

    opts.on('-p', '--output_kegg_pathways_file <file>', String, 'output kegg pathways file (default is keggpath.collapse)') do |o|
    options[:keggpath_file] = o
  end
    
    opts.on('-u', '--unique', "if r1 hit == r2 hit count them as 1") do |o|
    options[:uniq] = o
  end

end.parse!

options[:seed_file]     ||= 'seed.collapse'
options[:cat_file]      ||= 'cogcat.collapse'
options[:kegg_file]     ||= 'kegg.collapse'
options[:keggpath_file] ||= 'keggpath.collapse'
files		    	   = []
counts		  	   = {}
seeds		     	   = []
cogcats			     = []
cogcat_counts	   = Hash.new(0)
keggs		     	   = []
kegg_counts	     = Hash.new(0)
keggpaths        = []
keggpath_counts = Hash.new(0)
samplenames		   = []

# Make an array of all input samples
Dir.glob(options[:input_dir] + '/*emapper.annotations') do |item|
  files << item
end
# Use Bash to sum counts for each sample of seeds and cog categories
files.each do |file|
  count       	= []
  seedhash    	= {}
  cogcathash  	= {}
  cogcatcount 	= {}
  kegghash  	  = {}
  keggcount 	  = {}
  keggpathhash  = {}
  keggpathcount = {}
  if options[:uniq]
  	sumseeds = `cat #{file} | grep -v '^#' | cut -f 1,2 | sed 's/_[1-2]_0\t/\t/g' | sort -u | cut -f 2 | sort | uniq -c`
  	sumcogcats = `cat #{file} | grep -v '^#' | cut -f 1,10 | sed 's/_[1-2]_0\t/\t/g' | sort -u | cut -f 2 | sed -e $'s/, /\\\n/g' | sed '/^$/d' | sort | uniq -c`
  	sumkeggs = `cat #{file} | grep -v '^#' | cut -f 1,15 |  sed 's/_[1-2]_0\t/\t/g' | sort -u | cut -f 2 | sed -e $'s/ko://g' | sed -e $'s/,/\\\n/g' | sort | uniq -c | sed 's/-$/nil/g'`
    sumkeggpaths = `cat #{file} | grep -v '^#' | cut -f 1,16 |  sed 's/_[1-2]_0\t/\t/g' | sort -u | cut -f 2 | sed -e $'s/,/\\\n/g' | sort | uniq -c | sed 's/-$/nil/g'`
  else
  	sumseeds = `cat #{file} | grep -v '^#' | cut -f 2 | sort | uniq -c`
  	sumcogcats = `cat #{file} | grep -v '^#' | cut -f 10 | sed '/^$/d' | sed -e $'s/, /\\\n/g' | sort | uniq -c`
  	sumkeggs = `cat #{file} | grep -v '^#' | cut -f 15 | sed 's/ko://g' | sed -e $'s/,/\\\n/g' | sort | uniq -c | sed 's/-$/nil/g'`
    sumkeggpaths = `cat #{file} | grep -v '^#' | cut -f 16 | sed -e $'s/,/\\\n/g' | sort | uniq -c | sed 's/-$/nil/g'`
  end
# Make an array of the samplenames
  samplename  = file.split('/').last.split('.').first
  samplenames << samplename
# Make an array of the seeds and make a hash of hashes: samplenames -> seeds -> counts
  sumseeds.each_line do |line|
	 line.chomp!
	 fields = line.split("\t")
	 count = fields[0].split(' ')[0]
      seeds << fields[0].split(' ')[1]
      seed = fields[0].split(' ')[1]
      seedhash[seed] = count
      counts[samplename] = seedhash
  end
 # Make an array of the cogcats and make a hash of hashes: samplenames -> cogcats -> counts
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
# Make an array of the kegg orthologs and make a hash of hashes: samplenames -> KO -> counts
  sumkeggs.each_line do |line|
	  line.chomp!
      fields = line.split("\t")
      count = fields[0].split(' ')[0]
      keggs << fields[0].split(' ')[1].split(' ')
      kegg = fields[0].split(' ')[1].split(' ')
      kegg.each do
    	  kegghash[kegg] = count
      end
  end
  keggs.flatten.uniq.each do |uniq|
	  kegghash.each do |key, value|
    value.to_i
      key.each do |k|
       	if k == uniq
         	if keggcount.key?(uniq)
          	keggcount[uniq] += value.to_i
          else
          	keggcount[uniq] = value.to_i
          end
        end
      end
    end
  end
kegg_counts[samplename] = keggcount
# Make an array of the kegg pathways and make a hash of hashes: samplenames -> KEGG maps -> counts
  sumkeggpaths.each_line do |line|
    line.chomp!
      fields = line.split("\t")
      count = fields[0].split(' ')[0]
      keggpaths << fields[0].split(' ')[1].split(' ')
      keggpath = fields[0].split(' ')[1].split(' ')
      keggpath.each do
        keggpathhash[keggpath] = count
      end
  end
  keggpaths.flatten.uniq.each do |uniq|
    keggpathhash.each do |key, value|
    value.to_i
      key.each do |k|
        if k == uniq
          if keggpathcount.key?(uniq)
            keggpathcount[uniq] += value.to_i
          else
            keggpathcount[uniq] = value.to_i
          end
        end
      end
    end
  end
keggpath_counts[samplename] = keggpathcount
end

seeds.uniq!
cogcats.flatten!.uniq!
keggs.flatten!.uniq!
keggpaths.flatten!.uniq!

# Write seed summary
File.open(options[:seed_file], 'w') do |file|
  file.print("\t", seeds.join("\t"), "\n")
  counts.each do |sample, data|
    file.print(sample)
    seeds.each do |seed|
      if data.key?(seed)
        file.print("\t", data[seed])
      else
        file.print("\t0")
      end
    end
    file.print("\n")
  end
end

# Write cog category summary
File.open(options[:cat_file], 'w') do |file|
  file.print("\t", cogcats.join("\t"), "\n")
  cogcat_counts.each do |sample, data|
    file.print(sample)
    cogcats.each do |cog|
      if data.key?(cog)
        file.print("\t", data[cog])
      else
        file.print("\t0")
      end
    end
    file.print("\n")
  end
end

# Write KEGG orthology summary
File.open(options[:kegg_file], 'w') do |file|
  file.print("\t", keggs.join("\t"), "\n")
  kegg_counts.each do |sample, data|
    file.print(sample)
    keggs.each do |ko|
      if data.key?(ko)
        file.print("\t", data[ko])
      else
        file.print("\t0")
      end
    end
    file.print("\n")
  end
end


# Write KEGG pathway summary
File.open(options[:keggpath_file], 'w') do |file|
  file.print("\t", keggpaths.join("\t"), "\n")
  keggpath_counts.each do |sample, data|
    file.print(sample)
    keggpaths.each do |ko|
      if data.key?(ko)
        file.print("\t", data[ko])
      else
        file.print("\t0")
      end
    end
    file.print("\n")
  end
end
