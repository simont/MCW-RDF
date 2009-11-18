#! /opt/local/bin/ruby

require 'GeneRecord';

# TO DO - Add in option to FTP latest GENES file from RGD directly


file_name = ARGV[0] || "../spec/files/GENES_RAT.txt"

headings = String.new
records = Array.new

File.open(file_name,"r") do |file|

  while (line = file.gets)
    
    line.chomp!
    if headings == ""
      headings = line
    else
      if line != ""
        records << GeneRecord.new(headings,line)
      end
    end
    # puts "Records: #{records.size}"
  end
end

records.each do |gene|
  puts gene.to_rdf
end