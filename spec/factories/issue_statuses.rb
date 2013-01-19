Factory.define :issue_status do |f|
  f.sequence(:name) { |n| "status#{n}"}
end
