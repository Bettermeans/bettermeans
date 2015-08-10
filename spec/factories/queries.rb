Factory.define :query do |f|
  f.sequence(:name) { |n| "Query #{n}" }
end
