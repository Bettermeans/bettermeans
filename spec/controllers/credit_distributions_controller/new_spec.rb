require 'spec_helper'

describe CreditDistributionsController, '#new' do

  let(:admin_user) { Factory.create(:admin_user) }
  let(:xml_params) { { :format => 'xml' } }

  before(:each) { login_as(admin_user) }

  context 'format html' do
    it 'renders the "new" template' do
      get(:new)
      response.should render_template('credit_distributions/new')
    end
  end

  context 'format xml' do
    it 'renders a new credit_distribution as xml' do
      get(:new, xml_params)
      response.body.should == CreditDistribution.new.to_xml
    end
  end

end
