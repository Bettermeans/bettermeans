Given /^I am a ([^\"]*) of project "([^\"]*)"$/ do |role, project|
  Given "#{User.current.login} is a #{role} of project \"#{project}\""  
end


Given /([^\"]*) is a ([^\"]*) of project "([^\"]*)"$/ do |user,role, project|
  @project = Project.find(:first, :conditions => {:name => project})
  @role = Role.find(:first, :conditions => {:name => role})
  m = Member.new(:user => User.find(:first, :conditions => {:login => user}), :roles => [@role])
  @project.all_members << m  
end