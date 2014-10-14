require 'spec_helper'

describe EnterprisesController, '#new' do

  let(:xml_params) { { :format => 'xml' } }

  context 'format html' do
    it 'renders the "new" template' do
      get(:new)
      response.should render_template('enterprises/new')
    end
  end

  context 'format xml' do
    it 'renders a new enterprise as xml' do
      get(:new, xml_params)
      response.body.should == Enterprise.new.to_xml
    end
  end

end
