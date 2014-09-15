require 'spec_helper'

describe HelpSectionsController, '#create' do

  integrate_views

  let(:admin_user) { Factory.create(:admin_user) }
  let(:valid_params) { { :help_section => { :name => 'help me!' } } }
  let(:xml_params) { valid_params.merge(:format => 'xml') }

  before(:each) { login_as(admin_user) }

  context 'if the help section saves' do
    context 'format html' do
      it 'flashes a success message' do
        flash.stub(:sweep)
        post(:create, valid_params)
        flash[:success].should match(/successfully created/i)
      end

      it 'redirects to help sections show' do
        post(:create, valid_params)
        response.should redirect_to(assigns(:help_section))
      end

      it 'sets the fields on the help section' do
        post(:create, valid_params)
        HelpSection.first.name.should == 'help me!'
      end
    end

    context 'format xml' do
      it 'renders the help section as xml' do
        post(:create, xml_params)
        response.body.should == assigns(:help_section).to_xml
      end

      it 'renders status "Created"' do
        post(:create, xml_params)
        response.status.should == '201 Created'
      end

      it 'renders the location of the help section' do
        post(:create, xml_params)
        response.location.should == help_section_url(assigns(:help_section))
      end
    end
  end

  context 'if the help section does not save' do

    let(:help_section) { HelpSection.new }

    before(:each) do
      help_section.stub(:valid?).and_return(false)
      help_section.errors.add(:wat, 'an error')
      HelpSection.stub(:new).and_return(help_section)
    end

    context 'format html' do
      it 'renders the "new" template' do
        post(:create, valid_params)
        response.should render_template('help_sections/new')
      end
    end

    context 'format xml' do
      it 'renders the errors on the help section as xml' do
        post(:create, xml_params)
        response.body.should == help_section.errors.to_xml
      end

      it 'renders status "Unprocessable Entity"' do
        post(:create, xml_params)
        response.status.should == '422 Unprocessable Entity'
      end
    end
  end

end
