require 'spec_helper'

describe ReputationsController, '#new' do

  let(:xml_params) { { :format => 'xml' } }

  context 'format html' do
    it 'renders the "new" template' do
      get(:new)
      response.should render_template('reputations/new')
    end
  end

  context 'format xml' do
    it 'renders a new reputation as xml' do
      get(:new, xml_params)
      response.body.should == Reputation.new.to_xml
    end
  end

end
