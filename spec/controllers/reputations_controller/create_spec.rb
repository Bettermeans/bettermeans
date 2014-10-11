require 'spec_helper'

describe ReputationsController, '#create' do

  integrate_views

  let(:valid_params) { { :reputation => { :params => 'help me!' } } }
  let(:xml_params) { valid_params.merge(:format => 'xml') }

  context 'if the reputation saves' do
    context 'format html' do
      it 'flashes a success message' do
        flash.stub(:sweep)
        post(:create, valid_params)
        flash[:success].should match(/successfully created/i)
      end

      it 'redirects to reputations show' do
        post(:create, valid_params)
        response.should redirect_to(assigns(:reputation))
      end

      it 'sets the fields on the reputation' do
        post(:create, valid_params)
        reputation = Reputation.first
        reputation.params.should == 'help me!'
      end
    end

    context 'format xml' do
      it 'renders the reputation as xml' do
        post(:create, xml_params)
        response.body.should == assigns(:reputation).to_xml
      end

      it 'renders status "Created"' do
        post(:create, xml_params)
        response.status.should == '201 Created'
      end

      it 'renders the location of the reputation' do
        post(:create, xml_params)
        response.location.should == reputation_url(assigns(:reputation))
      end
    end
  end

  context 'if the reputation does not save' do

    let(:reputation) { Reputation.new }

    before(:each) do
      reputation.stub(:valid?).and_return(false)
      reputation.errors.add(:wat, 'an error')
      Reputation.stub(:new).and_return(reputation)
    end

    context 'format html' do
      it 'renders the "new" template' do
        post(:create, valid_params)
        response.should render_template('reputations/new')
      end
    end

    context 'format xml' do
      it 'renders the errors on the reputation as xml' do
        post(:create, xml_params)
        response.body.should == reputation.errors.to_xml
      end

      it 'renders status "Unprocessable Entity"' do
        post(:create, xml_params)
        response.status.should == '422 Unprocessable Entity'
      end
    end
  end

end
