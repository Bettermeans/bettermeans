Factory.define :workflow do |f|

  f.association :role, :factory => :role
  f.association :old_status, :factory => :issue_status
  f.association :new_status, :factory => :issue_status
  f.association :tracker, :factory => :tracker

end
