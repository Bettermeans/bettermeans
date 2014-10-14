require 'spec_helper'

describe EnterprisesController, '#show' do

  let(:enterprise) { Factory.create(:enterprise) }
  let(:valid_params) { { :id => enterprise.id } }
  let(:xml_params) { valid_params.merge(:format => 'xml') }

  context 'format html' do
    it 'renders the "show" template' do
      get(:show, valid_params)
      response.should render_template('enterprises/show')
    end
  end

  context 'format xml' do
    it 'renders the enterprise as xml' do
      get(:show, xml_params)
      response.body.should == enterprise.to_xml
    end
  end

end
