require 'spec_helper'

describe AdminController, '#test_email' do

  let(:admin_user) { Factory.create(:admin_user) }

  before(:each) { login_as(admin_user) }

  it('redirects to settings_controller/edit') do
    get(:test_email)
    path_params = {
      :controller => 'settings',
      :action => 'edit',
      :tab => 'notifications',
    }
    response.should redirect_to(path_params)
  end

end
