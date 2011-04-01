Given /^I am logged in$/ do 
  Given "I am logged in as \"brian_dennehy\""
end

Given /^I am logged in as "([^\"]*)"$/ do |username|
  @user = ensure_account username,username
  
  teardown { User.delete @user if @user }
  
  Then "Login in as #{username} with password #{username}"
  
  assert_not_contain "Invalid user or password"
end

Given /^I am not logged in$/ do
  visit url_for(:controller => 'account', :action => 'logout')
  @user = User.anonymous
end

Given /^I am(\snot)? an administrator$/ do |not_an_adminstrator|
  is_admin = not_an_adminstrator.nil? or not_an_adminstrator
  @user.admin = is_admin
  @user.save!
end

Given /^Login in as ([^\"]*) with password ([^\"]*)$/ do |username, password|
  visit url_for(:controller => 'account', :action => 'login')
  fill_in "username", :with => username
  fill_in "password", :with => password
  click_button "login"
end

When /^I go to Browse Bettermeans$/ do
  visit url_for(:controller => 'projects', :action => 'index')
  adapter = Webrat.adapter_class.new self
  @view = BrowseBettermeansView.new webrat_session
end

def ensure_account(username, password)
  result = User.find_by_login(username)
  
  result = create_account(username, password) unless result
  
  result
end

def create_account(username, password)
  new_user = User.new
  new_user.login = username    
  new_user.firstname = username
  new_user.lastname = username
  new_user.password = password 
  new_user.admin = false 
  new_user.mail = "#{username}@xxx.com"

  new_user.save!  
  
  new_user
end