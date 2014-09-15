require 'spec_helper'

describe SharesController, '#new' do

  integrate_views

  let(:xml_params) { { :format => 'xml' } }

  context 'format html' do
    it 'renders the "new" template' do
      get(:new)
      response.should render_template('shares/new')
    end
  end

  context 'format xml' do
    it 'renders a new share as xml' do
      get(:new, xml_params)
      response.body.should == Share.new.to_xml
    end
  end

end
