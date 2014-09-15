require 'spec_helper'

describe QuotesController, '#show' do

  integrate_views

  let(:quote) { Factory.create(:quote) }
  let(:valid_params) { { :id => quote.id } }
  let(:xml_params) { valid_params.merge(:format => 'xml') }

  context 'format html' do
    it 'renders the "show" template' do
      get(:show, valid_params)
      response.should render_template('quotes/show')
    end
  end

  context 'format xml' do
    it 'renders the quote as xml' do
      get(:show, xml_params)
      response.body.should == quote.to_xml
    end
  end

end
