# require 'integration/integration_helper'

feature 'Issues', :js => true do

  let(:user) { Factory.create(:user) }

  background do
    disable_help
    request_login_as(user)
  end

  scenario 'starting an issue' do
    pending
    click_link 'New workstream'
    page.should have_selector('#project_name')
    fill_in 'project_name', :with => 'Some Workstream'
    click_button 'Save'
    page.should have_content('In Progress')
    click_link 'Add New Item'
    fill_in 'new_title_input', :with => 'Some Issue'
    click_button 'Create'
    page.should have_link 'Some Issue'
    click_link 'Some Issue'

    within_frame(0) do
      page.should have_content 'Watch'
      page.should have_content 'Upload files'

      find('#issue_status').should have_content('Open')

      within('#issue_tags_container') do
        page.should have_xpath("//input[@default='add a tag']")
      end

      within('#todo_section_0') do
        page.should have_content 'Todos (0)'
        fill_in 'new_todo_0', :with => 'my task'
        click_button('Add')
        page.should have_content 'my task'
      end

      within('#item_content_buttons_0') do
        page.should_not have_content 'giveup'
        page.should_not have_content 'finish'
        page.should have_content 'start'
        find('#item_action_link_start0').click
        page.should have_content 'giveup'
        page.should have_content 'finish'
        page.should_not have_content 'start'
      end
    end
  end

end
