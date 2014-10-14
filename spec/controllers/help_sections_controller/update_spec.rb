require 'spec_helper'

describe HelpSectionsController, '#update' do

  let(:help_section) { Factory.create(:help_section) }
  let(:admin_user) { Factory.create(:admin_user) }
  let(:valid_params) do
    { :id => help_section.id, :help_section => { :name => 'my new name' } }
  end
  let(:xml_params) { valid_params.merge(:format => 'xml') }

  before(:each) { login_as(admin_user) }

  context 'when the help section updates' do
    context 'format html' do
      it 'flashes a success message' do
        flash.stub(:sweep)
        put(:update, valid_params)
        flash[:success].should match(/successfully updated/i)
      end

      it 'redirects to the help section show page' do
        put(:update, valid_params)
        response.should redirect_to(help_section)
      end

      it 'updates the fields on the help section' do
        put(:update, valid_params)
        help_section.reload.name.should == 'my new name'
      end
    end

    context 'format xml' do
      it 'renders status "OK"' do
        put(:update, xml_params)
        response.status.should == '200 OK'
      end
    end
  end

  context 'when the help section does not update' do
    before(:each) do
      help_section.stub(:valid?).and_return(false)
      help_section.errors.add(:wat, 'an error')
      HelpSection.stub(:find).and_return(help_section)
    end

    context 'format html' do
      it 'renders the "edit" template' do
        put(:update, valid_params)
      end
    end

    context 'format xml' do
      it 'renders the errors as xml' do
        put(:update, xml_params)
      end

      it 'renders status "Unprocessable Entity"' do
        put(:update, xml_params)
      end
    end
  end

end
