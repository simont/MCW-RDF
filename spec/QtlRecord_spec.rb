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
    @record = QtlRecord.new("QTL_RGD_ID\tQTL_SYMBOL\tQTL_NAME\t3.4_MAP_POS_CHR\t3.4_MAP_POS_START\t3.4_MAP_POS_STOP\tCURATED_REF_PUBMED_ID\tLOD\tP_VALUE\tSPECIES",
    "61324\tEae5\tExorcised attacking eulogies QTL 5\t5\t12345\t23456\t10323205;18281616;18453595\t3.4\t0.0004\trat")
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
    @record.to_rdf('CURATED_REF_PUBMED_ID').should == "<http://bio2rdf.org/rgd:61324> <http://bio2rdf.org/ns/bio2rdf#xPubMed> <http://bio2rdf.org/pubmed:10323205> .\n<http://bio2rdf.org/rgd:61324> <http://bio2rdf.org/ns/bio2rdf#xPubMed> <http://bio2rdf.org/pubmed:18281616> .\n<http://bio2rdf.org/rgd:61324> <http://bio2rdf.org/ns/bio2rdf#xPubMed> <http://bio2rdf.org/pubmed:18453595> ."


  end

  it "should contain LOD and p-value scores, if available" do
    @record.to_rdf('LOD').should == "<http://bio2rdf.org/rgd:61324> <http://bio2rdf.org/ns/rgd#lod> \"3.4\" ."
    @record.to_rdf('P_VALUE').should == "<http://bio2rdf.org/rgd:61324> <http://bio2rdf.org/ns/rgd#pvalue> \"0.0004\" ."
  end

  it "should record the correct taxon ID" do
    @record.to_rdf('SPECIES').should == "<http://bio2rdf.org/rgd:61324> <http://bio2rdf.org/ns/rgd#species> <http://bio2rdf.org/taxon:10116> ."
  end
end

describe "it should list strain data and more" do

  before(:each) do
    @record = QtlRecord.new("QTL_RGD_ID	SPECIES	QTL_SYMBOL	QTL_NAME	CHROMOSOME_FROM_REF	LOD	P_VALUE	VARIANCE	FLANK_1_RGD_ID	FLANK_1_SYMBOL	FLANK_2_RGD_ID	FLANK_2_SYMBOL	PEAK_RGD_ID	PEAK_MARKER_SYMBOL	TRAIT_NAME	SUBTRAIT_NAME	TRAIT_METHODOLOGY	PHENOTYPES	ASSOCIATED_DISEASES	CURATED_REF_RGD_ID	CURATED_REF_PUBMED_ID	CANDIDATE_GENE_RGD_IDS	CANDIDATE_GENE_SYMBOLS	INHERITANCE_TYPE	RELATED_QTLS	RATMAP_ID	3.4_MAP_POS_CHR	3.4_MAP_POS_START	3.4_MAP_POS_STOP	3.4_MAP_POS_METHOD	3.1_MAP_POS_CHR	3.1_MAP_POS_START	3.1_MAP_POS_STOP	3.1_MAP_POS_METHOD	STRAIN_RGD_IDS	STRAIN_RGD_SYMBOLS	CROSS_TYPE	CROSS_PAIR",
    "61325	rat	Aia5	Adjuvant induced arthritis QTL 5	10		0.01		61274	D10Arb20	61275	D10Arb22	10466	D10Mit1	Joint/bone inflammation	adjuvant induced	arthritis severity after adjuvant injection was measured via a cumulative scoring system for multiple joints; animals were evaluated twice a week for six weeks	joint swelling	Arthritis, Rheumatoid	625379	11953987				Cia3 and Pia5; reported to be the same as Aia3;Cia5	45641	10	24006429	110718848	2 - by one flank and peak markers	10	24007478	110733352	2 - by one flank and peak markers	61095;61114;631282	DA.F344(<i>Cia5</i>);DA/Bkl;DA.F344-(<I>D10Rat37-D10Arb22</I>)	Congenic	DA.F344 Congenic")
  end

  it "should list any and all strain RGD IDs used in the measurement of the QTL" do
    @record.to_rdf('STRAIN_RGD_IDS').should == "<http://bio2rdf.org/rgd:61325> <http://bio2rdf.org/ns/rgd#strainUsed> <http://bio2rdf.org/rgd:61095> .\n<http://bio2rdf.org/rgd:61325> <http://bio2rdf.org/ns/rgd#strainUsed> <http://bio2rdf.org/rgd:61114> .\n<http://bio2rdf.org/rgd:61325> <http://bio2rdf.org/ns/rgd#strainUsed> <http://bio2rdf.org/rgd:631282> ."

  end

end