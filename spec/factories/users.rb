Factory.define :user do |f|
  f.sequence(:login) { |n| "username#{n}" }
  f.password "password"
  f.sequence(:mail) { |n| "username#{n}@testing.com" }
  f.sequence(:firstname) { |n| "first#{n}" }
  f.sequence(:lastname) { |n| "last#{n}" }
end

