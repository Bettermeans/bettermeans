Factory.define :motion_vote do |f|

  f.association :user, :factory => :user
  f.association :motion, :factory => :motion

end
