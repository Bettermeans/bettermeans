require 'spec_helper'

include Redmine::Export::PDF

describe IFPDF, '#issue_to_pdf' do

  let(:pdf) { IFPDF.new('en') }
  let(:pdf_2) { IFPDF.new('en') }
  let(:project) { Factory.create(:project, :name => 'a project') }
  let(:issue) { Factory.create(:issue, :project => project) }

  before(:each) do
    # HACK: because to_pdf methods generate a new instance and we need to turn
    # off compression to verify the result
    pdf
    pdf_2.SetCompression(false)
    IFPDF.stub(:new).and_return(pdf_2)
  end

  it 'returns pdf output for the given issue, project, and query' do
    output = pdf.issue_to_pdf(issue)

    output.should include('a project')
  end

end
