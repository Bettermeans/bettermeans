require 'spec_helper'

describe AdminController, '#index' do

  let(:admin_user) { Factory.create(:admin_user) }

  before(:each) { login_as(admin_user) }

  it 'assigns @no_configuration_data' do
    get(:index)
    assigns(:no_configuration_data).should == false
  end

end
