require 'spec_helper'

describe QuotesController, '#index' do

  integrate_views

  let(:user) { Factory.create(:user) }
  let!(:quote) { Factory.create(:quote, :user => user) }

  context 'format html' do
    it 'renders the "index" template' do
      get(:index)
      response.should render_template('quotes/index')
    end
  end

  context 'format xml' do
    it 'renders all quotes as xml' do
      get(:index, :format => 'xml')
      response.body.should == [quote].to_xml
    end
  end

end
