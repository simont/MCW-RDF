# GeneRecord_spec.rb
require File.join(File.dirname(__FILE__), *%w[spec_helper])

describe "it should parse a QTL file" do

    #61324	rat	Eae5	Experimental allergic encephalomyelitis QTL 5

    it "should parse headers and a row of an RGD QTL file" do
      record = QtlRecord.new("QTL_RGD_ID\tQTL_SYMBOL","61324\tEae5")
      record.raw_data.should == ["61324", "Eae5"]
    end

    it "should parse headers by tab" do
            record = QtlRecord.new("QTL_RGD_ID\tQTL_SYMBOL","text1\ttext2")
            record.headers[0].should == "QTL_RGD_ID"
            record.number_of_columns.should == 2
          end
    
       it "should parse the data by tab also" do
         record = QtlRecord.new("QTL_RGD_ID\tQTL_SYMBOL","text1\ttext2")
         record.raw_data[0].should == "text1"
         record.raw_data[1].should == "text2"
       end
    
       it "should parse certain fields into data" do
         record = QtlRecord.new("QTL_RGD_ID\tQTL_SYMBOL\tQTL_NAME","text1\ttext2\tthe qtl")
         record.data['QTL_RGD_ID'].should == "text1"
         record.data['QTL_SYMBOL'].should == "text2"
         record.data['QTL_NAME'].should == "the qtl"
       end

end

describe "it should create appropriate RDF data from the QTL file" do
  
    before(:each) do
      @record = QtlRecord.new("QTL_RGD_ID\tQTL_SYMBOL\tQTL_NAME\t3.4_MAP_POS_CHR\t3.4_MAP_POS_START\t3.4_MAP_POS_STOP\tCURATED_REF_PUBMED_ID","61324\tEae5\tExorcised attacking eulogies QTL 5\t5\t12345\t23456\t12335")
    end

    it "should make the subject a URI based on the RGD ID" do
      @record.subject.should == "<http://bio2rdf.org/rgd:61324>"
    end
    
    it "should convert the symbol to appropriate RDF" do
      @record.to_rdf('QTL_SYMBOL').should == "<http://bio2rdf.org/rgd:61324> <http://bio2rdf.org/ns/bio2rdf#symbol> \"Eae5\" .\n<http://bio2rdf.org/symbol:Eae5> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://bio2rdf.org/ns/bio2rdf#Symbol> .\n<http://bio2rdf.org/symbol:Eae5> <http://www.w3.org/2002/07/owl#sameAs> <http://bio2rdf.org/rgd:61324> ."
      
    end
    
    it "should export the chromosome, start and stop of the 3.4 build" do
      @record.to_rdf('3.4_MAP_POS_CHR').should == "<http://bio2rdf.org/rgd:61324> <http://bio2rdf.org/ns/rgd#chromosome_34> \"5\" ."
      @record.to_rdf('3.4_MAP_POS_START').should == "<http://bio2rdf.org/rgd:61324> <http://bio2rdf.org/ns/rgd#chromosome_34_Start> \"12345\" ."
      @record.to_rdf('3.4_MAP_POS_STOP').should == "<http://bio2rdf.org/rgd:61324> <http://bio2rdf.org/ns/rgd#chromosome_34_Stop> \"23456\" ."
    end
    
    it "should export PMID to rdf" do
      @record.to_rdf('CURATED_REF_PUBMED_ID').should == "<http://bio2rdf.org/rgd:61324> <http://bio2rdf.org/ns/bio2rdf#xPubMed> <http://bio2rdf.org/pubmed:12335> ."
      
    end
    
end