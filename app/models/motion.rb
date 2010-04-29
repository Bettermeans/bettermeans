class Motion < ActiveRecord::Base  
  STATE_DEACTIVATED = -1
  STATE_ACTIVE = 0
  STATE_PASSED = 1
  STATE_DEFEATED = 2
  
  serialize :params

  belongs_to :project
  
  # named_scope :active, :conditions => ["state = 0"]
  # Returns all active, non responded, non-expired notifications
  named_scope :allactive, :conditions => ["state = #{STATE_ACTIVE}", Time.new.to_date]
  

end



# == Schema Information
#
# Table name: motions
#
#  id          :integer         not null, primary key
#  project_id  :integer
#  title       :string(255)
#  description :text
#  variation   :string(255)
#  params      :text
#  motion_type :integer
#  state       :integer
#  created_at  :datetime
#  updated_at  :datetime
#

