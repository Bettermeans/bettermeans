require 'spec_helper'

describe EnterprisesController, '#index' do

  integrate_views

  let!(:enterprise) { Factory.create(:enterprise) }

  context 'format html' do
    it 'renders the "index" template' do
      get(:index)
      response.should render_template('enterprises/index')
    end
  end

  context 'format xml' do
    it 'renders all enterprises as xml' do
      get(:index, :format => 'xml')
      response.body.should == [enterprise].to_xml
    end
  end

end
