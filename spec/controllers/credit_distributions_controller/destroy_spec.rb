require 'spec_helper'

describe CreditDistributionsController, '#destroy' do

  let(:admin_user) { Factory.create(:admin_user) }
  let(:credit_distribution) { Factory.create(:credit_distribution) }
  let(:valid_params) { { :id => credit_distribution.id } }
  let(:xml_params) { valid_params.merge(:format => 'xml') }

  before(:each) { login_as(admin_user) }

  it 'destroys the credit_distribution' do
    delete(:destroy, valid_params)
    CreditDistribution.find_by_id(credit_distribution.id).should be_nil
  end

  context 'format html' do
    it 'redirects to credit_distributions/index' do
      delete(:destroy, valid_params)
      response.should redirect_to(credit_distributions_path)
    end
  end

  context 'format xml' do
    it 'renders status "OK"' do
      delete(:destroy, xml_params)
      response.status.should == '200 OK'
    end
  end

end
