Factory.define :issue_priority do |f|
  f.sequence(:name) { |n| "pri#{n}" }
end
