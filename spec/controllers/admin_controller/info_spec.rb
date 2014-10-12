require 'spec_helper'

describe AdminController, '#info' do

  integrate_views

  let(:admin_user) { Factory.create(:admin_user) }

  before(:each) { login_as(admin_user) }

  it 'assigns @db_adapter_name' do
    get(:info)
    adapter_name = ActiveRecord::Base.connection.adapter_name
    assigns(:db_adapter_name).should == adapter_name
  end

end
