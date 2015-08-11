require 'spec_helper'

describe CreditDistributionsController, '#edit' do

  let(:admin_user) { Factory.create(:admin_user) }
  let(:credit_distribution) { Factory.create(:credit_distribution) }
  let(:valid_params) { { :id => credit_distribution.id } }

  before(:each) { login_as(admin_user) }

  it 'renders the "edit" template' do
    get(:edit, valid_params)
    response.should render_template('credit_distributions/edit')
  end

end
