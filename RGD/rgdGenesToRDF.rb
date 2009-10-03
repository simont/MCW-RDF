#! /opt/local/bin/ruby



require 'GeneRecord';

# TO DO - Add your Modules, Classes, etc

#parse file from command line

file_name = ARGV[0] || "./spec/files/GENES_RAT.txt"

headings = String.new
records = Array.new

File.open(file_name,"r") do |file|

  while (line = file.gets)
    
    line.chomp!
    if headings == ""
      headings = line
    else
      records << GeneRecord.new(headings,line)
    end
  end
end

records.each do |gene|
  puts gene.to_rdf
end