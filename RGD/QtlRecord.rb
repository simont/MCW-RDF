

class QtlRecord < RgdRecord

  def initialize(headers, data_row)
    @headers = headers.split("\t")
    @raw_data = data_row.split("\t")
    @data = Hash.new

    # list of data to parse from the file
    # QTL_RGD_ID	SPECIES	QTL_SYMBOL	QTL_NAME
    @fields_to_parse = ['QTL_RGD_ID','QTL_SYMBOL','QTL_NAME','3.4_MAP_POS_CHR','3.4_MAP_POS_START',	'3.4_MAP_POS_STOP','CURATED_REF_PUBMED_ID','LOD','P_VALUE',"SPECIES","STRAIN_RGD_IDS"]

    # Parse the data into the data hash
    parse_data

  end

  # Will return the subject clause as a bio2rdf URI based around the RGD ID of the gene
  def subject
    return "<http://bio2rdf.org/rgd:#{@data['QTL_RGD_ID']}>"
  end

  def process_field(field, file_data)
    output = Array.new

    if file_data != nil

      data = CGI::escapeHTML(file_data)
      if !data.empty?
        if field == "QTL_RGD_ID"
          output << process_QTL_RGD_ID(data)
        elsif field == "SPECIES"
          output << process_SPECIES(data)
        elsif field == "QTL_SYMBOL"
          output << process_SYMBOL(data)
        elsif field == "QTL_NAME"
          output << process_NAME(data)
        elsif field == "3.4_MAP_POS_CHR"
          output << process_CHROMOSOME_34(data)
        elsif field == "3.4_MAP_POS_START"
          output << process_START_POS_34(data)
        elsif field == "3.4_MAP_POS_STOP"
          output << process_STOP_POS_34(data)
        elsif field == "CURATED_REF_PUBMED_ID"
          output << process_CURATED_REF_PUBMED_ID(data)
        elsif field == "LOD"
          output << process_LOD(data)
        elsif field == "P_VALUE"
          output << process_P_VALUE(data)
        elsif field =="STRAIN_RGD_IDS"
          output << process_STRAIN_RGD_IDS(data)
        end
      end

      return output
    end
  end

  def process_QTL_RGD_ID(rgdid)
    @primary_id  = rgdid
    output = Array.new
    output.push( [self.subject, "<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>", "<http://bio2rdf.org/ns/rgd#Qtl>", "."].join(' ') )
    output.push( [self.subject, "<http://purl.org/dc/elements/1.1/identifier>", "\"rgd:#{@primary_id}\"", "."].join(' ') )
    output.push( [self.subject, "<http://www.w3.org/2000/01/rdf-schema#label>", "\"#{@data['QTL_NAME']} (#{@data['QTL_SYMBOL']}) [rgd:#{@primary_id}]\"", "."].join(' ') )
    return output
  end

  def process_LOD(lod)
    output = Array.new
    output.push( [self.subject, "<http://bio2rdf.org/ns/rgd#lod>", "\"#{lod}\"", "."].join(' ') )
    return output
  end


  # "<http://bio2rdf.org/rgd:61324> <http://bio2rdf.org/ns/rgd#lod> 
  def process_P_VALUE(p_value)
    output = Array.new
    output.push( [self.subject, "<http://bio2rdf.org/ns/rgd#pvalue>", "\"#{p_value}\"", "."].join(' ') )
    return output
  end

end