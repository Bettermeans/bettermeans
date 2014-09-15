require 'spec_helper'

describe SharesController, '#create' do

  integrate_views

  let(:valid_params) { { :share => { :amount => 52 } } }
  let(:xml_params) { valid_params.merge(:format => 'xml') }

  context 'if the share saves' do
    context 'format html' do
      it 'flashes a success message' do
        flash.stub(:sweep)
        post(:create, valid_params)
        flash[:success].should match(/successfully created/i)
      end

      it 'redirects to shares show' do
        post(:create, valid_params)
        response.should redirect_to(assigns(:share))
      end

      it 'sets the fields on the share' do
        post(:create, valid_params)
        share = Share.first
        share.amount.should == 52
      end
    end

    context 'format xml' do
      it 'renders the share as xml' do
        post(:create, xml_params)
        response.body.should == assigns(:share).to_xml
      end

      it 'renders status "Created"' do
        post(:create, xml_params)
        response.status.should == '201 Created'
      end

      it 'renders the location of the share' do
        post(:create, xml_params)
        response.location.should == share_url(assigns(:share))
      end
    end
  end

  context 'if the share does not save' do

    let(:share) { Share.new }

    before(:each) do
      share.stub(:valid?).and_return(false)
      share.errors.add(:wat, 'an error')
      Share.stub(:new).and_return(share)
    end

    context 'format html' do
      it 'renders the "new" template' do
        post(:create, valid_params)
        response.should render_template('shares/new')
      end
    end

    context 'format xml' do
      it 'renders the errors on the share as xml' do
        post(:create, xml_params)
        response.body.should == share.errors.to_xml
      end

      it 'renders status "Unprocessable Entity"' do
        post(:create, xml_params)
        response.status.should == '422 Unprocessable Entity'
      end
    end
  end

end
