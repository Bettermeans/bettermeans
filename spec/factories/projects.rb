Factory.define :project do |f|
  f.sequence(:name) { |n| "Name of project #{n}" }
  f.sequence(:identifier) { |n| "workstreamid#{n}" }
  f.status 1
  f.trackers Tracker.all
  f.is_public true
  f.enabled_module_names Redmine::AccessControl.available_project_modules
end
