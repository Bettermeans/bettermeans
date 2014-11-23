require 'spec_helper'

describe AdminController, '#test_email' do

  class FooError < StandardError; end

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

  it 'flashes an error when the test email fails' do
    flash.stub(:sweep)
    Mailer.stub(:deliver_test).and_raise(FooError)
    get(:test_email)
    flash[:error].should match(/an error occurred/i)
  end

end
