require 'spec_helper'

describe CreditDistributionsController, '#update' do

  let(:admin_user) { Factory.create(:admin_user) }
  let(:credit_distribution) { Factory.create(:credit_distribution) }
  let(:valid_params) do
    { :id => credit_distribution.id, :credit_distribution => { :amount => 36 } }
  end
  let(:xml_params) { valid_params.merge(:format => 'xml') }

  before(:each) { login_as(admin_user) }

  context 'when the credit_distribution updates' do
    context 'format html' do
      it 'flashes a success message' do
        flash.stub(:sweep)
        put(:update, valid_params)
        flash[:success].should match(/successfully updated/i)
      end

      it 'redirects to the credit_distribution show page' do
        put(:update, valid_params)
        response.should redirect_to(credit_distribution)
      end

      it 'updates the fields on the credit_distribution' do
        put(:update, valid_params)
        credit_distribution.reload.amount.should == 36
      end
    end

    context 'format xml' do
      it 'renders status "OK"' do
        put(:update, xml_params)
        response.status.should == '200 OK'
      end
    end
  end

  context 'when the credit_distribution does not update' do
    before(:each) do
      credit_distribution.stub(:valid?).and_return(false)
      credit_distribution.errors.add(:wat, 'an error')
      CreditDistribution.stub(:find).and_return(credit_distribution)
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
