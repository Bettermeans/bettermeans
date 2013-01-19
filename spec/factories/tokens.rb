Factory.define :token do |f|
  f.association :user
  f.action :autologin
end
