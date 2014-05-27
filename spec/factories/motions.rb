Factory.define :motion do |f|
  f.sequence(:description) { |n| "Motion description #{n}" }
  f.association :project, :factory => :project
end
