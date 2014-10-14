require 'spec_helper'

describe AdminController, '#user_data_dump' do

  let(:admin_user) { Factory.create(:admin_user) }

  before(:each) { login_as(admin_user) }

  it 'renders all active user records as csv' do
    get(:user_data_dump)
    output = StringIO.new
    response.body.call(nil, output)
    output.string.should match(/#{admin_user.login}/)
  end

end
