Factory.define :enterprise do |f|
  f.sequence(:name) { |n| "Name #{n}"}
  f.sequence(:description) { |n| "Description #{n}"}
  f.sequence(:homepage) { |n| "Homepage #{n}"}
end
