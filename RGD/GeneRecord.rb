

class GeneRecord < RgdRecord


  def initialize(headers, data_row)
    @headers = headers.split("\t")
    @raw_data = data_row.split("\t")
        
    @data = Hash.new

    # list of data to parse from the file
    @fields_to_parse = ['GENE_RGD_ID','SYMBOL','NAME','GENE_DESC','CHROMOSOME_34','START_POS_34','STOP_POS_34', 'CURATED_REF_PUBMED_ID','UNCURATED_REF_PUBMED_ID','ENTREZ_GENE', 'UNIPROT_ID', 'GENBANK_NUCLEOTIDE', 'GENBANK_PROTEIN', "GENE_TYPE"]

    # Parse the data into the data hash
    parse_data

  end
 


  # Will return the subject clause as a bio2rdf URI based around the RGD ID of the gene
  def subject
    return "<http://bio2rdf.org/rgd:#{@data['GENE_RGD_ID']}>"
  end

  
  def process_field(field, file_data)
    output = Array.new
   
    
    if file_data != nil
      
      data = CGI::escapeHTML(file_data)
      if !data.empty?
        
        if field == "GENE_RGD_ID"
          output << process_GENE_RGD_ID(data)
        elsif field == "SYMBOL"
          output << process_SYMBOL(data)
        elsif field == "NAME"
          output << process_NAME(data)
        elsif field == "CHROMOSOME_34"
          output << process_CHROMOSOME_34(data)
        elsif field == "START_POS_34"
          output << process_START_POS_34(data)
        elsif field == "STOP_POS_34"
          output << process_STOP_POS_34(data)
        elsif field == "CURATED_REF_PUBMED_ID"
          output << process_CURATED_REF_PUBMED_ID(data)
        elsif field == "UNCURATED_PUBMED_ID"
          # TODO decide if I want to treat curated and uncurated the same....
          output << process_CURATED_REF_PUBMED_ID(data)
        elsif field == "ENTREZ_GENE"         
          output << process_ENTREZ_GENE(data)
        elsif field == "UNIPROT_ID"         
          output << process_UNIPROT_ID(data)
        elsif field == "GENBANK_PROTEIN" || field == "GENBANK_NUCLEOTIDE"         
          output << process_GENBANK(data)
        elsif field == "GENE_TYPE"      
          output << process_GENE_TYPE(data)
        end
      end
    end
    
    return output
  end
  
  def process_GENE_RGD_ID(rgdid)
    @primary_id  = rgdid
    output = Array.new
    output.push( [self.subject, "<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>", "<http://bio2rdf.org/ns/rgd#Gene>", "."].join(' ') )
    output.push( [self.subject, "<http://purl.org/dc/elements/1.1/identifier>", "\"rgd:#{@data['GENE_RGD_ID']}\"", "."].join(' ') )
    output.push( [self.subject, "<http://www.w3.org/2000/01/rdf-schema#label>", "\"#{@data['NAME']} (#{@data['SYMBOL']}) [rgd:#{@data['GENE_RGD_ID']}]\"", "."].join(' ') )
    return output
  end
  
  def process_ENTREZ_GENE(geneid)
    output = Array.new
    output.push( [self.subject, "<http://bio2rdf.org/ns/bio2rdf#xGeneID>","<http://bio2rdf.org/geneid:#{geneid}>", "."].join(' ') )
    # For integration with neurocommons data
    output.push( [self.subject, "<http://www.w3.org/2002/07/owl#sameAs>","<http://purl.org/commons/record/ncbi_gene/#{geneid}>", "."].join(' ') )
    return output
  end

    
    def process_GENBANK(gbids)
      output = Array.new
      gbids.split(',').each do |gb|
        output.push( [self.subject, "<http://bio2rdf.org/ns/bio2rdf#xGenBank>", "<http://bio2rdf.org/genbank:#{gb.strip}>", "."].join(' ') )
      end
      return output
    end
    
    def process_GENE_TYPE(type)
      output = Array.new
      output.push( [self.subject, "<http://bio2rdf.org/ns/bio2rdf#subType>", "\"#{type}\"", "."].join(' ') )
      return output
    end
    
end