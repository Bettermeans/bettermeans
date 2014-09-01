require 'spec_helper'

include Redmine::Export::PDF

describe IFPDF, '#Cell' do

  let(:pdf) { IFPDF.new('en') }

  before(:each) { pdf.SetY(10) }

  it 'writes a string to the output' do
    pdf.should_receive(:out).with('BT 31.19 795.77 Td (some string) Tj ET')
    cell = pdf.Cell(5, 10, 'some string')
  end

end
