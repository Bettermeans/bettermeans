require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Feature name", %q{
  In order to ...
  As a ...
  I want to ...
} do

  scenario "Scenario name" do
    visit '/'
    page.should have_content('Open, Democratic Project Management')
    click_link 'sign up'
    page.should have_content('Plans and Pricing')
    page.should have_content('Pricing FAQ’s')
    within '.free-box' do
      click_link 'Sign up'
    end
    page.should have_content('or create an account')
    fill_in 'Username', :with => 'example'
    fill_in 'Password', :with => '123456'
    fill_in 'Retype Password', :with => '123456'
    fill_in 'Firstname', :with => 'John'
    fill_in 'Lastname', :with => 'Doe'
    fill_in 'Email', :with => 'example@example.org'
    click_button 'Sign up'
    page.should have_content('Account was successfully created')
    user = User.find_by_mail('example@example.org')
    user.status = User::STATUS_ACTIVE
    user.save
  end
end
