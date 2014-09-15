require 'spec_helper'

describe HelpSectionsController, '#show' do

  integrate_views

  let(:help_section) { Factory.create(:help_section) }
  let(:admin_user) { Factory.create(:admin_user) }
  let(:valid_params) { { :id => help_section.id } }
  let(:xml_params) { valid_params.merge(:format => 'xml') }

  before(:each) { login_as(admin_user) }

  context 'when the help section shows' do
    context 'format html' do
      it 'renders the show template' do
        get(:show, valid_params)
        response.should render_template('help_sections/show')
      end
    end

    context 'format xml' do
      it 'renders the help section as xml' do
        get(:show, xml_params)
        response.body.should == help_section.to_xml
      end
    end
  end

  context 'when the help section does not show' do
    before(:each) do
      HelpSection.stub(:find).and_return(help_section)
      help_section.stub(:show).and_return(false)
    end

    context 'format html' do
      it 'renders nothing' do
        get(:show, valid_params)
        response.body.should be_blank
      end
    end
  end

end
