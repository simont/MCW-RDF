# GeneRecord_spec.rb

require 'GeneRecord'

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

  it "should make the subject a URI based on the RGD ID" do
    record = GeneRecord.new("GENE_RGD_ID\tSYMBOL\tNAME\tGENE_DESC","1001\ttext2\tthe gene\tinfo about gene")
    record.subject.should == "<http://bio2rdf.org/rgd:1001>"
  end
  
  # 727913  A3galt2 alpha 1,3-galactosyltransferase 2 UDP-galactose: beta-d-galactosyl-1,4-glucosylceramide alpha-1, 3-galactosyltransferase; involved in the synthesis of the isoglobo-series of glycosphingolipids
  
  it "should convert the name to appropriate RDF" do
    record = GeneRecord.new("GENE_RGD_ID\tSYMBOL\tNAME\tGENE_DESC","1000\tAbc1\tthe gene\tinfo about gene")
    output = record.process_NAME("alpha 1,3-galactosyltransferase")
    output.should == ["<http://bio2rdf.org/rgd:1000> <http://purl.org/dc/elements/1.1/title> \"alpha 1,3-galactosyltransferase\" ."]
  end

end

describe "Parsing PMIDS" do
  
  it "should parse a single PMID correctly" do
    record = GeneRecord.new("GENE_RGD_ID\tSYMBOL\tNAME\tGENE_DESC","1000\tAbc1\tthe gene\tinfo about gene")
    output = record.process_CURATED_REF_PUBMED_ID("12335")
    output.should == ["<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xPubMed> <http://bio2rdf.org/pubmed:12335> ."]
  end
  
  it "should parse a list of PMIDs correctly" do
    record = GeneRecord.new("GENE_RGD_ID\tSYMBOL\tNAME\tGENE_DESC","1000\tAbc1\tthe gene\tinfo about gene")
    output = record.process_CURATED_REF_PUBMED_ID("12335, 54321,678910")
    output.should == ["<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xPubMed> <http://bio2rdf.org/pubmed:12335> .",
      "<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xPubMed> <http://bio2rdf.org/pubmed:54321> .",
      "<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xPubMed> <http://bio2rdf.org/pubmed:678910> ."]
  end
  
end

describe "Parsing other xrefs" do
  
  it "should parse an entrez gene ID correctly" do
    record = GeneRecord.new("GENE_RGD_ID\tSYMBOL\tNAME\tGENE_DESC","1000\tAbc1\tthe gene\tinfo about gene")
    output = record.process_ENTREZ_GENE("1234")
    output.should == ["<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xGeneID> <http://bio2rdf.org/geneid:1234> ."]
  end
  
  it "should parse a single UNIPROT correctly" do
    record = GeneRecord.new("GENE_RGD_ID\tSYMBOL\tNAME\tGENE_DESC","1000\tAbc1\tthe gene\tinfo about gene")
    output = record.process_UNIPROT_ID("P12335")
    output.should == ["<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xPath> <http://bio2rdf.org/uniprot:P12335> ."]
  end
  
  it "should parse a list of UNIPROT IDs correctly" do
    record = GeneRecord.new("GENE_RGD_ID\tSYMBOL\tNAME\tGENE_DESC","1000\tAbc1\tthe gene\tinfo about gene")
    output = record.process_UNIPROT_ID("P12335,Q54321,P65432")
    output.should == [
      "<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xPath> <http://bio2rdf.org/uniprot:P12335> .",
      "<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xPath> <http://bio2rdf.org/uniprot:Q54321> .",
      "<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xPath> <http://bio2rdf.org/uniprot:P65432> .",
      ]
  end
  
   it "should parse a single ENSEMBL_ID correctly" do
    record = GeneRecord.new("GENE_RGD_ID\tSYMBOL\tNAME\tGENE_DESC","1000\tAbc1\tthe gene\tinfo about gene")
    output = record.process_ENSEMBL_ID("ENSRNO12345678")
    output.should == ["<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xENSEMBL> <http://bio2rdf.org/ensembl:ENSRNO12345678> ."]
  end
  
   it "should parse a single Genbank  correctly" do
    record = GeneRecord.new("GENE_RGD_ID\tSYMBOL\tNAME\tGENE_DESC","1000\tAbc1\tthe gene\tinfo about gene")
    output = record.process_GENBANK("NP_036620")
    output.should == ["<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xGenBank> <http://bio2rdf.org/genbank:NP_036620> ."]
  end
  
  it "should parse multiple Genbank entries correctly" do
    record = GeneRecord.new("GENE_RGD_ID\tSYMBOL\tNAME\tGENE_DESC","1000\tAbc1\tthe gene\tinfo about gene")
    output = record.process_GENBANK("NP_036620,EDM02007,EDM02008")
    output.should == [
      "<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xGenBank> <http://bio2rdf.org/genbank:NP_036620> .",
      "<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xGenBank> <http://bio2rdf.org/genbank:EDM02007> .",
      "<http://bio2rdf.org/rgd:1000> <http://bio2rdf.org/ns/bio2rdf#xGenBank> <http://bio2rdf.org/genbank:EDM02008> ."
      ]
  end
end