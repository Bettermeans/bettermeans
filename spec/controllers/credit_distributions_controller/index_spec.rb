require 'spec_helper'

describe CreditDistributionsController, '#index' do

  let(:admin_user) { Factory.create(:admin_user) }
  let!(:credit_distribution) { Factory.create(:credit_distribution) }

  before(:each) { login_as(admin_user) }

  context 'format html' do
    it 'renders the "index" template' do
      get(:index)
      response.should render_template('credit_distributions/index')
    end
  end

  context 'format xml' do
    it 'renders all credit_distributions as xml' do
      get(:index, :format => 'xml')
      response.body.should == [credit_distribution].to_xml
    end
  end

end
