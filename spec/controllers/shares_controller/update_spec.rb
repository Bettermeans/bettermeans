require 'spec_helper'

describe SharesController, '#update' do

  let(:share) { Factory.create(:share) }
  let(:valid_params) do
    { :id => share.id, :share => { :amount => 52 } }
  end
  let(:xml_params) { valid_params.merge(:format => 'xml') }

  context 'when the share updates' do
    context 'format html' do
      it 'flashes a success message' do
        flash.stub(:sweep)
        put(:update, valid_params)
        flash[:success].should match(/successfully updated/i)
      end

      it 'redirects to the share show page' do
        put(:update, valid_params)
        response.should redirect_to(share)
      end

      it 'updates the fields on the share' do
        put(:update, valid_params)
        share.reload.amount.should == 52
      end
    end

    context 'format xml' do
      it 'renders status "OK"' do
        put(:update, xml_params)
        response.status.should == '200 OK'
      end
    end
  end

  context 'when the share does not update' do
    before(:each) do
      share.stub(:valid?).and_return(false)
      share.errors.add(:wat, 'an error')
      Share.stub(:find).and_return(share)
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
