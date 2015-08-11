require 'spec_helper'

describe CreditDistributionsController, '#show' do

  let(:admin_user) { Factory.create(:admin_user) }
  let(:credit_distribution) { Factory.create(:credit_distribution) }
  let(:valid_params) { { :id => credit_distribution.id } }
  let(:xml_params) { valid_params.merge(:format => 'xml') }

  before(:each) { login_as(admin_user) }

  context 'format html' do
    it 'renders the "show" template' do
      get(:show, valid_params)
      response.should render_template('credit_distributions/show')
    end
  end

  context 'format xml' do
    it 'renders the credit_distribution as xml' do
      get(:show, xml_params)
      response.body.should == credit_distribution.to_xml
    end
  end

end
