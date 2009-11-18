# GeneRecord_spec.rb

require File.dirname(__FILE__) + '/../RGD/GeneRecord'
require 'rubygems'
require 'curb'

describe "GeneRecord data parsing" do

  it "should parse headers and a row of an RGD Genes file" do
    record = GeneRecord.new("GENE_RGD_ID\tSYMBOL","text1\ttext2")
    record.raw_data.should == ["text1", "text2"]
  end
  
  it "should parse headers by tab" do
    record = GeneRecord.new("GENE_RGD_ID\tSYMBOL","text1\ttext2")
    record.headers[0].should == "GENE_RGD_ID"
    record.number_of_columns.should == 2
  end
  
  it "should parse the data by tab also" do
    record = GeneRecord.new("GENE_RGD_ID\tSYMBOL","text1\ttext2")
    record.raw_data[0].should == "text1"
    record.raw_data[1].should == "text2"
  end
  
  it "should parse certain fields into data" do
    record = GeneRecord.new("GENE_RGD_ID\tSYMBOL\tNAME\tGENE_DESC","text1\ttext2\tthe gene\tinfo about gene")
    record.data['GENE_RGD_ID'].should == "text1"
    record.data['SYMBOL'].should == "text2"
    record.data['NAME'].should == "the gene"
    record.data['GENE_DESC'].should == "info about gene"
  end
  
end

describe "GeneRecord to RDF" do

  before(:each) do
    @record =  GeneRecord.new("GENE_RGD_ID\tSYMBOL\tNAME\tGENE_DESC","1000\tAbc1\tthe gene\tinfo about gene")
  end

  it "should make the subject a URI based on the RGD ID" do
    @record.subject.should == "<http://bio2rdf.org/rgd:1000>"
  end
  
  # 727913  A3galt2 alpha 1,3-galactosyltransferase 2 UDP-galactose: beta-d-galactosyl-1,4-glucosylceramide alpha-1, 3-galactosyltransferase; involved in the synthesis of the isoglobo-series of glycosphingolipids
  
  it "should convert the name to appropriate RDF" do
    output = @record.process_NAME("alpha 1,3-galactosyltransferase")
    output.should == ["<http://bio2rdf.org/rgd:1000> <http://purl.org/dc/elements/1.1/title> \"alpha 1,3-galactosyltransferase\" ."]
  end

end

describe "Parsing PMIDS" do
  
  before(:each) do
    @record =  GeneRecord.new("GENE_RGD_ID\tSYMBOL\tNAME\tGENE_DESC","1000\tAbc1\tthe gene\tinfo about gene")
  end
  
  it "should parse a single PMID correctly" do
    output = @record.process_CURATED_REF_PUBMED_ID("12335")
    output.should == ["<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xPubMed> <http://bio2rdf.org/pubmed:12335> ."]
  end
  
  it "should parse a list of PMIDs correctly" do
    output = @record.process_CURATED_REF_PUBMED_ID("12335, 54321,678910")
    output.should == ["<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xPubMed> <http://bio2rdf.org/pubmed:12335> .",
      "<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xPubMed> <http://bio2rdf.org/pubmed:54321> .",
      "<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xPubMed> <http://bio2rdf.org/pubmed:678910> ."]
  end
  
end

describe "Parsing other xrefs" do
  
  before(:each) do
    @record =  GeneRecord.new("GENE_RGD_ID\tSYMBOL\tNAME\tGENE_DESC","1000\tAbc1\tthe gene\tinfo about gene")
  end
  
  it "should parse an entrez gene ID correctly" do
    output = @record.process_ENTREZ_GENE("1234")
    output.should == ["<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xGeneID> <http://bio2rdf.org/geneid:1234> ."]
  end
  
  it "should parse a single UNIPROT correctly" do
    output = @record.process_UNIPROT_ID("P12335")
    output.should == ["<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xUniprot> <http://bio2rdf.org/uniprot:P12335> ."]
  end
  
  it "should parse a list of UNIPROT IDs correctly" do
    output = @record.process_UNIPROT_ID("P12335,Q54321,P65432")
    output.should == [
      "<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xUniprot> <http://bio2rdf.org/uniprot:P12335> .",
      "<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xUniprot> <http://bio2rdf.org/uniprot:Q54321> .",
      "<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xUniprot> <http://bio2rdf.org/uniprot:P65432> .",
      ]
  end
  
   it "should parse a single ENSEMBL_ID correctly" do
    output = @record.process_ENSEMBL_ID("ENSRNO12345678")
    output.should == ["<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xENSEMBL> <http://bio2rdf.org/ensembl:ENSRNO12345678> ."]
  end
  
   it "should parse multiple ENSEMBL_ID correctly" do
    output = @record.process_ENSEMBL_ID("ENSRNO12345678,ENSRNO12345679,ENSRNO12345680")
    output.should == [
      "<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xENSEMBL> <http://bio2rdf.org/ensembl:ENSRNO12345678> .",
      "<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xENSEMBL> <http://bio2rdf.org/ensembl:ENSRNO12345679> .",
      "<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xENSEMBL> <http://bio2rdf.org/ensembl:ENSRNO12345680> ."
      ]
  end
  
   it "should parse a single Genbank correctly" do
    output = @record.process_GENBANK("NP_036620")
    output.should == ["<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xGenBank> <http://bio2rdf.org/genbank:NP_036620> ."]
  end
  
  it "should parse multiple Genbank entries correctly" do
    output = @record.process_GENBANK("NP_036620,EDM02007,EDM02008")
    output.should == [
      "<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xGenBank> <http://bio2rdf.org/genbank:NP_036620> .",
      "<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xGenBank> <http://bio2rdf.org/genbank:EDM02007> .",
      "<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xGenBank> <http://bio2rdf.org/genbank:EDM02008> ."
      ]
  end
end


describe "it should put out ancilliary RDF too" do
  
  before(:each) do
    @record = GeneRecord.new("GENE_RGD_ID\tSYMBOL\tNAME\tGENE_DESC\rGENE_TYPE","1000\tAbc1\tthe gene\tinfo about gene\tprotein-coding")
  end  

  
  it "should output bio2rdf#subtype data" do
    output = @record.process_GENE_TYPE('protein-coding')
    output.should == ["<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#subType> \"protein-coding\" ."]
  end
  
  it "should put out appropriate info on names, symbols, etc." do
     output = @record.process_GENE_RGD_ID('1000')
      output.should == ["<http://bio2rdf.org/rgd:1000> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://bio2rdf.org/ns/rgd#Gene> .",
      "<http://bio2rdf.org/rgd:1000> <http://purl.org/dc/elements/1.1/identifier> \"rgd:1000\" .",
      "<http://bio2rdf.org/rgd:1000> <http://www.w3.org/2000/01/rdf-schema#label> \"the gene (Abc1) [rgd:1000]\" ."]
  end
  
  it "should put out info about the symbol" do
    output = @record.process_SYMBOL('Abc1')
      output.should == ["<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#symbol> \"Abc1\" .",
      "<http://bio2rdf.org/symbol:Abc1> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://bio2rdf.org/ns/bio2rdf#Symbol> .",
      "<http://bio2rdf.org/symbol:Abc1> <http://www.w3.org/2002/07/owl#sameAs> <http://bio2rdf.org/rgd:1000> .",]
  end
end