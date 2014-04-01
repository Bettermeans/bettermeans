require 'integration/integration_helper'

feature 'Issues', :js => true do

  let(:user) { Factory.create(:user) }

  background do
    HelpSection.stub(:first).and_return(double(:show => false))
    request_login_as(user)
  end

  scenario 'starting an issue' do
    click_link 'New workstream'
    page.should have_selector('#project_name')
    fill_in 'project_name', :with => 'Some Workstream'
    click_button 'Save'
    page.should have_content('In Progress')
    click_link 'Add New Item'
    fill_in 'new_title_input', :with => 'Some Issue'
  end

end
