require 'spec_helper'

describe SharesController, '#show' do

  integrate_views

  let(:share) { Factory.create(:share) }
  let(:valid_params) { { :id => share.id } }
  let(:xml_params) { valid_params.merge(:format => 'xml') }

  context 'format html' do
    it 'renders the "show" template' do
      get(:show, valid_params)
      response.should render_template('shares/show')
    end
  end

  context 'format xml' do
    it 'renders the share as xml' do
      get(:show, xml_params)
      response.body.should == share.to_xml
    end
  end

end
