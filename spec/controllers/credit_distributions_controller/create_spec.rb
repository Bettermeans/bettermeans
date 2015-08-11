require 'spec_helper'

describe CreditDistributionsController, '#create' do

  let(:admin_user) { Factory.create(:admin_user) }
  let(:user) { Factory.create(:user) }
  let(:project) { Factory.create(:project) }
  let(:distribution_params) do
    { :user => user, :project => project, :amount => 36 }
  end
  let(:valid_params) { { :credit_distribution => distribution_params } }
  let(:xml_params) { valid_params.merge(:format => 'xml') }

  before(:each) { login_as(admin_user) }

  context 'if the credit_distribution saves' do
    context 'format html' do
      it 'flashes a success message' do
        flash.stub(:sweep)
        post(:create, valid_params)
        flash[:success].should match(/successfully created/i)
      end

      it 'redirects to credit_distributions show' do
        post(:create, valid_params)
        response.should redirect_to(assigns(:credit_distribution))
      end

      it 'sets the fields on the credit_distribution' do
        post(:create, valid_params)
        credit_distribution = CreditDistribution.first
        credit_distribution.amount.should == 36
      end
    end

    context 'format xml' do
      it 'renders the credit_distribution as xml' do
        post(:create, xml_params)
        response.body.should == assigns(:credit_distribution).to_xml
      end

      it 'renders status "Created"' do
        post(:create, xml_params)
        response.status.should == '201 Created'
      end

      it 'renders the location of the credit_distribution' do
        post(:create, xml_params)
        response.location.should == credit_distribution_url(assigns(:credit_distribution))
      end
    end
  end

  context 'if the credit_distribution does not save' do

    let(:credit_distribution) { CreditDistribution.new }

    before(:each) do
      credit_distribution.stub(:valid?).and_return(false)
      credit_distribution.errors.add(:wat, 'an error')
      CreditDistribution.stub(:new).and_return(credit_distribution)
    end

    context 'format html' do
      it 'renders the "new" template' do
        post(:create, valid_params)
        response.should render_template('credit_distributions/new')
      end
    end

    context 'format xml' do
      it 'renders the errors on the credit_distribution as xml' do
        post(:create, xml_params)
        response.body.should == credit_distribution.errors.to_xml
      end

      it 'renders status "Unprocessable Entity"' do
        post(:create, xml_params)
        response.status.should == '422 Unprocessable Entity'
      end
    end
  end

end
