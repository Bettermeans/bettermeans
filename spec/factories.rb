Factory.define :project do |f|
  f.sequence(:name) { |n| "Name of project #{n}" }
  f.sequence(:identifier) { |n| "workstreamid#{n}" }
  f.status 1
  f.trackers Tracker.all
  f.is_public true
  f.enabled_module_names Redmine::AccessControl.available_project_modules
end

Factory.define :user do |f|
  f.sequence(:login) { |n| "username#{n}" }
  f.password "password"
  f.sequence(:mail) { |n| "username#{n}@testing.com" }
  f.sequence(:firstname) { |n| "first#{n}" }
  f.sequence(:lastname) { |n| "last#{n}" } 
end

Factory.define :tracker do |f|
  f.sequence(:position) { |n| "#{n}"}
  f.sequence(:name) { |n| "tracker#{n}"}
end

Factory.define :issue_status do |f|
  f.sequence(:name) { |n| "status#{n}"}
end

Factory.define :enterprise do |f|
  f.sequence(:name) { |n| "Name #{n}"}
  f.sequence(:description) { |n| "Description #{n}"}
  f.sequence(:homepage) { |n| "Homepage #{n}"}
end

Factory.define :issue_priority do |f|
  f.sequence(:name) { |n| "pri#{n}" }
end

Factory.define :issue do |f|
  f.sequence(:subject) { |n| "Subject #{n}"}
  f.sequence(:description) { |n| "Description #{n}"}
  f.association :tracker, :factory => :tracker
  f.association :project, :factory => :project
  f.association :author, :factory => :user
  f.association :status, :factory => :issue_status
  # f.status IssueStatus.find(1)
  # f.status Factory.attributes_for(:issue_status)
  f.association :status, :factory => :issue_status
  f.association :priority, :factory => :issue_priority
  f.priority IssuePriority.find(4)
  # f.priority Factory.attributes_for(:issue_priority)
end