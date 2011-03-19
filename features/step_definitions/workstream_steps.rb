Given /^I am a ([^\"]*) of project "([^\"]*)"$/ do |role, project|
  Given "#{user.username} is a #{role} of project \"#{project}\""  
end


Given /([^\"]*) is a ([^\"]*) of project "([^\"]*)"$/ do |user, role, project|
  @project = Project.find(:first, :conditions => {:name => project})
  @role = Role.find(:first, :conditions => {:name => role})
  m = Member.new(:user => User.find(:first, :conditions => {:login => user}), :roles => [@role])
  @project.all_members << m  
end

Given /I have one private workstream/ do
  member = Member.new(:user => @user, :roles => [Role.administrator])
  project = Project.new()
  project.name = "Private #{Time.now.to_s}"
  project.is_public = false
  project.save!
  project.members << member
  @projects = []
  @projects << project
end

Then /^it shows in the Latest Public Workstreams list$/ do
  within "div.project-summary" do |scope|     
    scope.should contain @projects.first.name
  end
end

Then /^it does not show in the Latest Public Workstreams list$/ do
    assert_not_contain @projects.first.name
end

After do
  if @projects
    #@projects.each {|project| project.delete}
  end
end