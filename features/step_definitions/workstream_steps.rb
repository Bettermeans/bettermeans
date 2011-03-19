def new_private_project(name)
  result = Project.new()
  result.name = name
  result.is_public = false
  result.save!  
  result
end

def new_public_project(name)
  result = Project.new()
  result.name = name
  result.is_public = true
  result.save!  
  result
end

def projects; @projects ||= []; end

Given /^there is one private workstream I am not a member of$/ do
  projects << new_private_project("[#{Time.now.to_i}] Someone else's private")
end

Given /I have one private workstream/ do
  member = Member.new(:user => @user, :roles => [Role.administrator])
  project = new_private_project("[#{Time.now.to_i}] My private")
  project.members << member
    
  projects << project
end

Given /^there is one public workstream I am not a member of$/ do
  projects << new_public_project("[#{Time.now.to_i}] Any public workstream")  
end

Given /^there is one public workstream I am a member of$/ do
  projects << new_public_project("[#{Time.now.to_i}] Any public workstream")  
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
    @projects.each {|project| project.delete}
  end
end