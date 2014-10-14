require 'spec_helper'

describe ReputationsController, '#show' do

  let(:reputation) { Factory.create(:reputation) }
  let(:valid_params) { { :id => reputation.id } }
  let(:xml_params) { valid_params.merge(:format => 'xml') }

  context 'format html' do
    it 'renders the "show" template' do
      get(:show, valid_params)
      response.should render_template('reputations/show')
    end
  end

  context 'format xml' do
    it 'renders the reputation as xml' do
      get(:show, xml_params)
      response.body.should == reputation.to_xml
    end
  end

end
