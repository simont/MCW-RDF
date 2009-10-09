#! /opt/local/bin/ruby

# Very basic hack to take a tab delimted file such as those created by Biomart and convert
# to some sort of RDF mapping Affy probsets to chips and to RGD IDs


file_name = ARGV[0] || "../spec/files/biomartAffytoRDF_test.txt"
chip_set = ARGV[1] || "rae230b"

File.open(file_name,"r") do |file|

  while (line = file.gets)
    
    line.chomp!
    (rgd,probeset) = line.split("\t")
    if !rgd.empty? && !probeset.empty?
      puts "<http://bio2rdf.org/rgd:#{rgd}> <http://bio2rdf.org/ns/bio2rdf#xAffymetrix> <http://bio2rdf.org/ns/affymetrix:#{probeset}> ."
      puts "<http://bio2rdf.org/affymetrix:#{probeset}> <http://bio2rdf.org/ns/bio2rdf#partOf> <http://bio2rdf.org/ns/affymetrix:#{chip_set}> ."
    end
  end
end
