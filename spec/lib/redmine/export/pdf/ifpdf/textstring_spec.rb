require 'spec_helper'

include Redmine::Export::PDF

describe IFPDF, '#textstring' do

  let(:pdf) { IFPDF.new('en') }

  it 'returns the string when it is hex-dumped' do
    hex_string = '<FEFF0062006C006100670068>'
    pdf.textstring(hex_string).should == hex_string
  end

  it 'returns the string escaped and in parens when it is not hex-dumped' do
    pdf.textstring('bl()agh').should == '(bl\\(\\)agh)'
  end

end
