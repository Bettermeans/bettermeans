require 'spec_helper'

describe QuotesController, '#create' do

  let(:user) { Factory.create(:user) }
  let(:valid_params) { { :quote => { :body => 'help me!' } } }
  let(:xml_params) { valid_params.merge(:format => 'xml') }

  before(:each) { login_as(user) }

  context 'if the quote saves' do
    context 'format html' do
      it 'flashes a success message' do
        flash.stub(:sweep)
        post(:create, valid_params)
        flash[:success].should match(/successfully created/i)
      end

      it 'redirects to quotes show' do
        post(:create, valid_params)
        response.should redirect_to(assigns(:quote))
      end

      it 'sets the fields on the quote' do
        post(:create, valid_params)
        quote = Quote.first
        quote.body.should == 'help me!'
        quote.user.should == user
      end
    end

    context 'format xml' do
      it 'renders the quote as xml' do
        post(:create, xml_params)
        response.body.should == assigns(:quote).to_xml
      end

      it 'renders status "Created"' do
        post(:create, xml_params)
        response.status.should == '201 Created'
      end

      it 'renders the location of the quote' do
        post(:create, xml_params)
        response.location.should == quote_url(assigns(:quote))
      end
    end
  end

  context 'if the quote does not save' do

    let(:quote) { Quote.new }

    before(:each) do
      quote.stub(:valid?).and_return(false)
      quote.errors.add(:wat, 'an error')
      Quote.stub(:new).and_return(quote)
    end

    context 'format html' do
      it 'renders the "new" template' do
        post(:create, valid_params)
        response.should render_template('quotes/new')
      end
    end

    context 'format xml' do
      it 'renders the errors on the quote as xml' do
        post(:create, xml_params)
        response.body.should == quote.errors.to_xml
      end

      it 'renders status "Unprocessable Entity"' do
        post(:create, xml_params)
        response.status.should == '422 Unprocessable Entity'
      end
    end
  end

end
