require 'spec_helper'

describe EnterprisesController, '#update' do

  let(:enterprise) { Factory.create(:enterprise) }
  let(:valid_params) do
    { :id => enterprise.id, :enterprise => { :name => 'my new name' } }
  end
  let(:xml_params) { valid_params.merge(:format => 'xml') }

  context 'when the enterprise updates' do
    context 'format html' do
      it 'flashes a success message' do
        flash.stub(:sweep)
        put(:update, valid_params)
        flash[:success].should match(/successfully updated/i)
      end

      it 'redirects to the enterprise show page' do
        put(:update, valid_params)
        response.should redirect_to(enterprise)
      end

      it 'updates the fields on the enterprise' do
        put(:update, valid_params)
        enterprise.reload.name.should == 'my new name'
      end
    end

    context 'format xml' do
      it 'renders status "OK"' do
        put(:update, xml_params)
        response.status.should == '200 OK'
      end
    end
  end

  context 'when the enterprise does not update' do
    before(:each) do
      enterprise.stub(:valid?).and_return(false)
      enterprise.errors.add(:wat, 'an error')
      Enterprise.stub(:find).and_return(enterprise)
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
