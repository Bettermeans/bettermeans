require 'spec_helper'

include Redmine::Export::PDF

describe IFPDF, '#SetFontStyle' do

  let(:pdf) { IFPDF.new('en') }

  it 'sets the font with the given style' do
    pdf.should_receive(:SetFont).with('arial', 'foo', 52)
    pdf.SetFontStyle('foo', 52)
  end

end
