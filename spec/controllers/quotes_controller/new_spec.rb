require 'spec_helper'

describe QuotesController, '#new' do

  let(:xml_params) { { :format => 'xml' } }

  context 'format html' do
    it 'renders the "new" template' do
      get(:new)
      response.should render_template('quotes/new')
    end
  end

  context 'format xml' do
    it 'renders a new quote as xml' do
      get(:new, xml_params)
      response.body.should == Quote.new.to_xml
    end
  end

end
