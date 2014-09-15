require 'spec_helper'

describe QuotesController, '#update' do

  integrate_views

  let(:quote) { Factory.create(:quote) }
  let(:valid_params) do
    { :id => quote.id, :quote => { :body => 'my new body' } }
  end
  let(:xml_params) { valid_params.merge(:format => 'xml') }

  context 'when the quote updates' do
    context 'format html' do
      it 'flashes a success message' do
        flash.stub(:sweep)
        put(:update, valid_params)
        flash[:success].should match(/successfully updated/i)
      end

      it 'redirects to the quote show page' do
        put(:update, valid_params)
        response.should redirect_to(quote)
      end

      it 'updates the fields on the quote' do
        put(:update, valid_params)
        quote.reload.body.should == 'my new body'
      end
    end

    context 'format xml' do
      it 'renders status "OK"' do
        put(:update, xml_params)
        response.status.should == '200 OK'
      end
    end
  end

  context 'when the quote does not update' do
    before(:each) do
      quote.stub(:valid?).and_return(false)
      quote.errors.add(:wat, 'an error')
      Quote.stub(:find).and_return(quote)
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
