Factory.define :board do |f|
  f.sequence(:name) { |n| "board-name #{n}" }
  f.sequence(:description) { |n| "board-description #{n}" }
  f.association :project, :factory => :project
end
