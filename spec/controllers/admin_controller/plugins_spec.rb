require 'spec_helper'

describe AdminController, '#plugins' do

  let(:admin_user) { Factory.create(:admin_user) }

  before(:each) { login_as(admin_user) }

  it 'assigns @plugins' do
    get(:plugins)
    assigns(:plugins).should == Redmine::Plugin.all
  end

end
