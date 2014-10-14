require 'spec_helper'

describe QuotesController, '#destroy' do

  let(:quote) { Factory.create(:quote) }
  let(:valid_params) { { :id => quote.id } }
  let(:xml_params) { valid_params.merge(:format => 'xml') }

  it 'destroys the quote' do
    delete(:destroy, valid_params)
    Quote.find_by_id(quote.id).should be_nil
  end

  context 'format html' do
    it 'redirects to quotes/index' do
      delete(:destroy, valid_params)
      response.should redirect_to(quotes_path)
    end
  end

  context 'format xml' do
    it 'renders status "OK"' do
      delete(:destroy, xml_params)
      response.status.should == '200 OK'
    end
  end

end
