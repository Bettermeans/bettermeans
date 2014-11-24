Factory.define :role do |f|

  f.sequence(:name) { |n| "Role #{n}" }

end
