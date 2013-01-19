Factory.define :invitation do |f|
  f.association :project, :factory => :project
end
