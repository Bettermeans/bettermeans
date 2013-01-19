Factory.define :tracker do |f|
  f.sequence(:position) { |n| "#{n}"}
  f.sequence(:name) { |n| "tracker#{n}"}
end
