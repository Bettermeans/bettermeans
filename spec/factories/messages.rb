Factory.define :message do |f|
  f.association :board, :factory => :board
  f.sequence(:subject) { |n| "message-subject #{n}" }
  f.sequence(:content) { |n| "message-content #{n}" }
end
