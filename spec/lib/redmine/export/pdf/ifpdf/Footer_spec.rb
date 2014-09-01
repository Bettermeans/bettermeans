require 'spec_helper'

include Redmine::Export::PDF

describe IFPDF, '#Footer' do

  let(:pdf) { IFPDF.new('en') }

  it 'writes a footer to the output' do
    pdf.should_receive(:out).with('2 J').twice
    pdf.should_receive(:out).with('0.57 w').twice
    pdf.should_receive(:out).with('BT /F1 8.00 Tf ET').twice
    pdf.should_receive(:out).with('').twice
    pdf.should_receive(:out).with('BT 528.13 33.03 Td (1/{nb}) Tj ET')
    pdf.should_receive(:out).with('BT 528.13 804.05 Td (1/{nb}) Tj ET')
    pdf.Footer
  end

end
