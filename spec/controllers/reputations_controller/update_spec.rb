require 'spec_helper'

describe ReputationsController, '#update' do

  let(:reputation) { Factory.create(:reputation) }
  let(:valid_params) do
    { :id => reputation.id, :reputation => { :params => 'my new params' } }
  end
  let(:xml_params) { valid_params.merge(:format => 'xml') }

  context 'when the reputation updates' do
    context 'format html' do
      it 'flashes a success message' do
        flash.stub(:sweep)
        put(:update, valid_params)
        flash[:success].should match(/successfully updated/i)
      end

      it 'redirects to the reputation show page' do
        put(:update, valid_params)
        response.should redirect_to(reputation)
      end

      it 'updates the fields on the reputation' do
        put(:update, valid_params)
        reputation.reload.params.should == 'my new params'
      end
    end

    context 'format xml' do
      it 'renders status "OK"' do
        put(:update, xml_params)
        response.status.should == '200 OK'
      end
    end
  end

  context 'when the reputation does not update' do
    before(:each) do
      reputation.stub(:valid?).and_return(false)
      reputation.errors.add(:wat, 'an error')
      Reputation.stub(:find).and_return(reputation)
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
