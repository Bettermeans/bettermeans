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
  end
end
