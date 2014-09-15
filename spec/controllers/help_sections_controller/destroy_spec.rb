require 'spec_helper'

describe HelpSectionsController, '#destroy' do

  integrate_views

  let(:help_section) { Factory.create(:help_section) }
  let(:admin_user) { Factory.create(:admin_user) }
  let(:valid_params) { { :id => help_section.id } }
  let(:xml_params) { valid_params.merge(:format => 'xml') }

  before(:each) { login_as(admin_user) }

  it 'destroys the help section' do
    delete(:destroy, valid_params)
    HelpSection.find_by_id(help_section.id).should be_nil
  end

  context 'format html' do
    it 'redirects to help_sections/index' do
      delete(:destroy, valid_params)
      response.should redirect_to(help_sections_path)
    end
  end

  context 'format xml' do
    it 'renders status "OK"' do
      delete(:destroy, xml_params)
      response.status.should == '200 OK'
    end
  end

end
