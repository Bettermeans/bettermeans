require 'spec_helper'

include Redmine::Export::PDF

describe IFPDF, '#initialize' do

  after(:each) { ::I18n.locale = :en }

  it 'sets the language' do
    IFPDF.new('zh')
    ::I18n.locale.should == :zh
  end

  context 'given "ja" for language' do
    let(:pdf) { IFPDF.new('ja') }

    it 'sets content font to "sjis"' do
      pdf.instance_variable_get(:@font_for_content).should == 'sjis'
    end

    it 'sets footer font to "SJIS"' do
      pdf.instance_variable_get(:@font_for_footer).should == 'SJIS'
    end
  end

  context 'given "zh" for language' do
    let(:pdf) { IFPDF.new('zh') }

    it 'sets content font to "gb"' do
      pdf.instance_variable_get(:@font_for_content).should == 'gb'
    end

    it 'sets footer font to "GB"' do
      pdf.instance_variable_get(:@font_for_footer).should == 'GB'
    end
  end

  context 'given "zh_tw" for language' do
    let(:pdf) { IFPDF.new('zh_tw') }

    it 'sets content font to "big5"' do
      pdf.instance_variable_get(:@font_for_content).should == 'big5'
    end

    it 'sets footer font to "Big5"' do
      pdf.instance_variable_get(:@font_for_footer).should == 'Big5'
    end
  end

  context 'given any other language' do
    let(:pdf) { IFPDF.new('it') }

    it 'sets content font to "arial"' do
      pdf.instance_variable_get(:@font_for_content).should == 'arial'
    end

    it 'sets footer font to "Helvetica"' do
      pdf.instance_variable_get(:@font_for_footer).should == 'Helvetica'
    end
  end

end
