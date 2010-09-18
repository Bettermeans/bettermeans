class Member < ActiveRecord::Base
end

# == Schema Information
#
# Table name: members
#
#  id                :integer         not null, primary key
#  user_id           :integer         default(0), not null
#  project_id        :integer         default(0), not null
#  created_at        :datetime
#  mail_notification :boolean         default(FALSE), not null
#

