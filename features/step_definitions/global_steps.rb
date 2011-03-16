Given /^I am logged in as ([^\"]*)$/ do |username|
  Then "Login in as #{username} with password #{username}"
  assert_not_contain "Invalid user or password"
end

Given /^Login in as ([^\"]*) with password ([^\"]*)$/ do |username, password|
  visit url_for(:controller => 'account', :action => 'login')
  fill_in "username", :with => username
  fill_in "password", :with => password
  click_button "login"
end