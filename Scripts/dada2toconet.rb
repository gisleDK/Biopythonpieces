#!/usr/bin/env ruby
# Written for ruby 2.2.2p95
# V0.01 Written by Gisle Vestergaard (gislevestergaard@gmail.com)

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

  opts.on('-i', '--in_otu <file>', String, 'Input tabulated ASV table with silva taxonomy') do |o|
    options[:input_file] = o
  end

  opts.on('-o', '--output_otu <file>', String, 'output CONET compatible ASV table (default is conet.tsv)') do |o|
    options[:output_file] = o
  end

  	opts.on('-n', '--numeric', "Rename ASVs using numeric values ") do |o|
    options[:numeric] = o
  end

end.parse!

options[:output_file] ||= 'conet.tsv'

counter = 0

if File.exists?(options[:input_file]) == false
	puts (options[:input_file]) + " not found"
	exit
end

=begin
if File.exists?(options[:output_file]) == true
	puts (options[:output_file]) + " already exists"
	exit
end
=end
if options[:numeric]
	File.open(options[:input_file], 'r') do |infile|
		infile.each_line do |line|
			line.chomp!
			if line.start_with?('#')
				File.open(options[:output_file], 'a') do |outfile|
	  				outfile.puts(line)
				end
			else
				fields = line.split("\t")
				taxonomy = fields.last
				taxonomy = taxonomy.gsub('"', '')
				sanity = taxonomy.split("; ")
				sanity.each do |s|
					unless s.include? ("D")
						print "illegal taxonomy " + taxonomy + "\n"	
						exit
					end
				end
				id = fields.first
				id = counter + 1
				counter = counter + 1
				taxonomy = taxonomy.split("; D_7__").first
				if taxonomy.include? "D_0__"
					taxonomy = taxonomy.gsub('D_0__', 'k__')
					if taxonomy.include? "D_1__"
						taxonomy = taxonomy.gsub('D_1__', 'p__')
						if taxonomy.include? "D_2__"
							taxonomy = taxonomy.gsub('D_2__', 'c__')
							if taxonomy.include? "D_3__"
								taxonomy = taxonomy.gsub('D_3__', 'o__')
								if taxonomy.include? "D_4__"
									taxonomy = taxonomy.gsub('D_4__', 'f__')
									if taxonomy.include? "D_5__"
										taxonomy = taxonomy.gsub('D_5__', 'g__')
										if taxonomy.include? "D_6__"
											taxonomy = taxonomy.gsub('D_6__', 's__')
										else 
											taxonomy = taxonomy + "; s__"
										end
									else 
										taxonomy = taxonomy + "; g__; s__"
									end
								else 
									taxonomy = taxonomy + "; f__; g__; s__"
								end
							else
								taxonomy = taxonomy + "; o__; f__; g__; s__"
							end
						else
							taxonomy = taxonomy + "; c__; o__; f__; g__; s__"
						end
					else
						taxonomy = taxonomy + "; p__; c__; o__; f__; g__; s__"
					end
				else
					taxonomy = taxonomy + "k__; p__; c__; o__; f__; g__; s__"
				end
				fields[0] = id
				fields[-1] = taxonomy
				File.open(options[:output_file], 'a') do |outfile|
	  				outfile.puts(fields.join("\t") + "\n")
				end
			end
		end
	end
else
	File.open(options[:input_file], 'r') do |infile|
		infile.each_line do |line|
			line.chomp!
			if line.start_with?('#')
				File.open(options[:output_file], 'a') do |outfile|
	  				outfile.puts(line)
				end
			else
				fields = line.split("\t")
				taxonomy = fields.last
				taxonomy = taxonomy.gsub('"', '')
				sanity = taxonomy.split("; ")
				sanity.each do |s|
					unless s.include? ("D")
						print "illegal taxonomy " + taxonomy + "\n"	
						exit
					end
				end
				taxonomy = taxonomy.split("; D_7__").first
				if taxonomy.include? "D_0__"
					taxonomy = taxonomy.gsub('D_0__', 'k__')
					if taxonomy.include? "D_1__"
						taxonomy = taxonomy.gsub('D_1__', 'p__')
						if taxonomy.include? "D_2__"
							taxonomy = taxonomy.gsub('D_2__', 'c__')
							if taxonomy.include? "D_3__"
								taxonomy = taxonomy.gsub('D_3__', 'o__')
								if taxonomy.include? "D_4__"
									taxonomy = taxonomy.gsub('D_4__', 'f__')
									if taxonomy.include? "D_5__"
										taxonomy = taxonomy.gsub('D_5__', 'g__')
										if taxonomy.include? "D_6__"
											taxonomy = taxonomy.gsub('D_6__', 's__')
										else 
											taxonomy = taxonomy + "; s__"
										end
									else 
										taxonomy = taxonomy + "; g__; s__"
									end
								else 
									taxonomy = taxonomy + "; f__; g__; s__"
								end
							else
								taxonomy = taxonomy + "; o__; f__; g__; s__"
							end
						else
							taxonomy = taxonomy + "; c__; o__; f__; g__; s__"
						end
					else
						taxonomy = taxonomy + "; p__; c__; o__; f__; g__; s__"
					end
				else
					taxonomy = taxonomy + "k__; p__; c__; o__; f__; g__; s__"
				end
				fields[-1] = taxonomy
				File.open(options[:output_file], 'a') do |outfile|
	  				outfile.puts(fields.join("\t") + "\n")
				end
			end
		end
	end
end
