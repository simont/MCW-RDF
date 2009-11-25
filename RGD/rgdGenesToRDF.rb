#! /opt/local/bin/ruby

require 'RgdRecord';
require 'GeneRecord';
require 'QtlRecord';

# TO DO - Add in option to FTP latest GENES file from RGD directly


file_type = "qtl" 
file_name = "../spec/files/QTLS_RAT.txt"

if !ARGV.empty? 
  file_type,file_name = ARGV
end

headings = String.new
records = Array.new

File.open(file_name,"r") do |file|

  while (line = file.gets)
    
    line.chomp!
    if headings == ""
      headings = line
    else
      if line != ""
        if file_type == 'gene'
          records << GeneRecord.new(headings,line)
        elsif file_type == 'qtl'
          records << QtlRecord.new(headings,line)
        end
      end
    end
    # puts "Records: #{records.size}"
  end
end

records.each do |record|
  puts record.to_rdf
end