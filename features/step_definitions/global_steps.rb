def create_account(username, password)
  new_user = User.new
  new_user.login = username    
  new_user.firstname = username
  new_user.lastname = username
  new_user.password = password 
  new_user.mail = "#{username}@xxx.com"

  new_user.save!
  new_user
end

Given /^I am logged in$/ do 
  Given "I am logged in as \"any_example_user\""
end

Given /^I am logged in as "([^\"]*)"$/ do |username|
  @user = create_account username,username
  
  Then "Login in as #{username} with password #{username}"
  
  assert_not_contain "Invalid user or password"
end

Given /^Login in as ([^\"]*) with password ([^\"]*)$/ do |username, password|
  visit url_for(:controller => 'account', :action => 'login')
  fill_in "username", :with => username
  fill_in "password", :with => password
  click_button "login"
end

When /^I go to Browse Bettermeans$/ do
  visit url_for(:controller => 'projects', :action => 'index')
end

After do
  User.delete @user if @user
end