# Given /^the following (.+) records?$/ do |factory, table|
#   # table is a Cucumber::Ast::Table
#   table.hashes.each do |hash|
#     Factory(factory,hash)
#   end
# end
# 
Given /^I am logged in as ([^\"]*)$/ do |username|
  Then "Login in as #{username} with password #{username}"
end


Given /^Login in as ([^\"]*) with password ([^\"]*)$/ do |username, password|
  visit url_for(:controller => 'account', :action => 'login')
  fill_in "Login", :with => username
  fill_in "Password", :with => password
  click_button "Login"
end