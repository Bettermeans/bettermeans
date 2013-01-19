Factory.define :issue do |f|
  f.sequence(:subject) { |n| "Subject #{n}"}
  f.sequence(:description) { |n| "Description #{n}"}
  f.association :tracker, :factory => :tracker
  f.association :project, :factory => :project
  f.association :author, :factory => :user
  f.association :status, :factory => :issue_status
  f.association :priority, :factory => :issue_priority
end
