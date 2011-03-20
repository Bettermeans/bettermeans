Given /^there is one private workstream I am not a member of$/ do
  projects << new_private_project("[#{Time.now.to_i}] Someone else's private")
end

Given /I have one private workstream/ do
  project = new_private_project("[#{Time.now.to_i}] My private")
  
  add_me_as_a_member_of project
    
  projects << project  
end

Given /^there is one public workstream I am(\snot)? a member of$/ do |not_a_member|
  projects << project = new_public_project("[#{Time.now.to_i}] Any public workstream")  
  add_me_as_a_member_of project unless not_a_member
end

Given /^the anonymous user is a member$/ do
  fail("No project yet, can't add anonymous as a member") unless projects.first
  add_as_member User.anonymous, projects.first
end

Then /^it shows in the Latest Public Workstreams list$/ do
  within "div.project-summary" do |scope|     
    scope.should contain @projects.first.name
  end
end

Then /^it does not show in the Latest Public Workstreams list$/ do
  project_summary_selector = "div.project-summary"  
  
  has_project_summary = have_selector(project_summary_selector).matches?(response_body)
  
  if has_project_summary  
    within project_summary_selector do |scope|     
      scope.should_not contain @projects.first.name
    end
  end
end

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

def add_me_as_a_member_of(project)  
  add_as_member @user, project
end

def add_as_member(user, project)
  project.members << Member.new(:user => user, :roles => [Role.administrator])
end

def projects; @projects ||= []; end

After do
  if @projects
    @projects.each {|project| project.delete} unless skip_teardown?
  end
end