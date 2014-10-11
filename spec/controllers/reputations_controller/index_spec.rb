require 'spec_helper'

describe ReputationsController, '#index' do

  integrate_views

  let!(:reputation) { Factory.create(:reputation) }

  context 'format html' do
    it 'renders the "index" template' do
      get(:index)
      response.should render_template('reputations/index')
    end
  end

  context 'format xml' do
    it 'renders all reputations as xml' do
      get(:index, :format => 'xml')
      response.body.should == [reputation].to_xml
    end
  end

end
