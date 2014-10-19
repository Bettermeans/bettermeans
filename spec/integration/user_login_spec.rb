require 'integration/integration_helper'

feature 'User login', :js => true do

  let(:user) { Factory.create(:user, :status => 1) }

  scenario 'a user is able to log in' do
    pending
    visit '/'
    page.should have_content('Open, Democratic Project Management')
    click_link 'login'
    fill_in('username', :with => user.login)
    fill_in('password', :with => user.password)
    click_button('Login »')
    page.should have_content('MY WORKSTREAMS')
    page.should have_content('Sign out')
  end

end
