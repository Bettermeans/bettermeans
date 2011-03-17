def create_account(username, password)
  fail "Missing username" if username.empty?
  
  new_user = User.new
  new_user.login = username    
  new_user.firstname = username
  new_user.lastname = username
  new_user.password = password 
  new_user.mail = "xxx@xxx.com"

  new_user.save(:validate => true)
  new_user
end

Given /^I am logged in as ([^\"]*)$/ do |username|
  @logged_in_as = create_account username,username
  
  Then "Login in as #{username} with password #{username}"
  
  assert_not_contain "Invalid user or password"
end

Given /^Login in as ([^\"]*) with password ([^\"]*)$/ do |username, password|
  visit url_for(:controller => 'account', :action => 'login')
  fill_in "username", :with => username
  fill_in "password", :with => password
  click_button "login"
end

After do
  User.delete @logged_in_as if @logged_in_as 
end