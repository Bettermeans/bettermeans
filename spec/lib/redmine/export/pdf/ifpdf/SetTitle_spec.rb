require 'spec_helper'

include Redmine::Export::PDF

describe IFPDF, '#SetTitle' do

  let(:pdf) { IFPDF.new('en') }

  it 'sets the title of the pdf to a UTF-16 representation' do
    pdf.SetTitle('blagh')
    pdf.instance_variable_get(:@title).should == '<FEFF0062006C006100670068>'
  end

  it 'it sets it to the bare text when the conversion breaks' do
    Iconv.should_receive(:conv).and_raise('wah!')
    pdf.SetTitle('blagh')
    pdf.instance_variable_get(:@title).should == 'blagh'
  end

end
