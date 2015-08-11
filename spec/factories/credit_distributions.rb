Factory.define :credit_distribution do |f|
  f.amount 52
  f.association :project
  f.association :user
end
