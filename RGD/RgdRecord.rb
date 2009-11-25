require 'cgi'

class RgdRecord
  
  
  attr_reader :raw_data, :data, :headers

  # quick references table for the standard taxons we have to deal with at RGD.
  TAXON = {'rattus norvegicus' => '10116',
          'rat' => '10116',
          'homo sapiens' => '9606',
          'human' => '9606',
          'mus musculus' => '10090',
          'mouse' => '10090'
          }

  def initialize(headers, data_row)
    @primary_id = ""
    @fields_to_parse = Array.new
    
  end

  def number_of_columns
     return @headers.size
   end
   
   # Will return the subject clause as a bio2rdf URI based around the RGD ID of the gene
   def subject
     return "<http://bio2rdf.org/rgd:#{@primary_id}>"
   end
   
   def to_rdf(*fileField)

     output = Array.new
     if fileField.empty?
       @fields_to_parse.each do |field|
         output << process_field(field, data[field])
       end
     else
       fileField.each do |field|
         output << process_field(field, data[field])   
       end
     end

     return output.flatten.join("\n")
   end
   

   def parse_data
     @headers.each do |h|
       if @fields_to_parse.include?(h) && @raw_data[@headers.index(h)] != nil
         @data[h] = @raw_data[@headers.index(h)].strip
       end
     end
   end
   
   def process_SYMBOL(symbol)
     output = Array.new
     output.push( [self.subject, "<http://bio2rdf.org/ns/bio2rdf#symbol>", '"' << symbol << '"', "."].join(' ') )
     output.push(["<http://bio2rdf.org/symbol:#{symbol}>","<http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://bio2rdf.org/ns/bio2rdf#Symbol>", "."].join(' '))
     output.push(["<http://bio2rdf.org/symbol:#{symbol}>", "<http://www.w3.org/2002/07/owl#sameAs>", self.subject, "."].join(' ') )
     return output

   end
   
   def process_SPECIES(species)
     output = Array.new
     output.push( [self.subject, "<http://bio2rdf.org/ns/rgd#species>", "<http://bio2rdf.org/taxon:#{TAXON[species]}>", "."].join(' ') )
     return output
   end

   def process_NAME(name)
     output = Array.new
     output.push( [self.subject, "<http://purl.org/dc/elements/1.1/title>", '"' << name << '"', "."].join(' ') )
     return output
   end

   def process_CHROMOSOME_34(chr)
     output = Array.new
     output.push( [self.subject, "<http://bio2rdf.org/ns/rgd#chromosome_34>", '"' << chr << '"', "."].join(' ') )
     return output
   end

   def process_START_POS_34(start)
     output = Array.new
     output.push( [self.subject, "<http://bio2rdf.org/ns/rgd#chromosome_34_Start>", '"' << start << '"', "."].join(' ') )
     return output
   end

   def process_STOP_POS_34(stop)
     output = Array.new
     output.push( [self.subject, "<http://bio2rdf.org/ns/rgd#chromosome_34_Stop>", '"' << stop << '"', "."].join(' ') )
     return output
   end

   def process_CURATED_REF_PUBMED_ID(pmids)
     output = Array.new
     pmids.split(/,|;/).each do |pmid|
       output.push( [self.subject, "<http://bio2rdf.org/ns/bio2rdf#xPubMed>", "<http://bio2rdf.org/pubmed:#{pmid.strip}>", "."].join(' ') )
     end
     return output
   end
   
   def process_UNIPROT_ID(unip)
      output = Array.new
      unip.split(',').each do |uid|
        output.push( [self.subject, "<http://bio2rdf.org/ns/bio2rdf#xUniprot>", "<http://bio2rdf.org/uniprot:#{uid.strip}>", "."].join(' ') )
      end
      return output
    end

    def process_ENSEMBL_ID(unip)
       output = Array.new
       unip.split(',').each do |uid|
         output.push( [self.subject, "<http://bio2rdf.org/ns/bio2rdf#xENSEMBL>", "<http://bio2rdf.org/ensembl:#{uid.strip}>", "."].join(' ') )
       end
       return output
     end
     
     def process_STRAIN_RGD_IDS(strain_ids)
       output = Array.new
        strain_ids.split(';').each do |str|
          output.push( [self.subject, "<http://bio2rdf.org/ns/rgd#strainUsed>", "<http://bio2rdf.org/rgd:#{str}>", "."].join(' ') )
        end
        return output
     end
  
end
