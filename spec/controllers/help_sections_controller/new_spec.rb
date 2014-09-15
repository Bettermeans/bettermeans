require 'spec_helper'

describe HelpSectionsController, '#new' do

  integrate_views

  let(:admin_user) { Factory.create(:admin_user) }
  let(:xml_params) { { :format => 'xml' } }

  before(:each) { login_as(admin_user) }

  context 'format html' do
    it 'renders the "new" template' do
      get(:new)
      response.should render_template('help_sections/new')
    end
  end

  context 'format xml' do
    it 'renders a new help section as xml' do
      get(:new, xml_params)
      response.body.should == HelpSection.new.to_xml
    end
  end

end
