class Share < ActiveRecord::Base
  
  default_value_for :issued_on do
    Time.now
  end
  
  
  #Constants
  VARIATION_FOUNDER = 1 #issue when enterprise starts. don't expire
  VARIATION_CREDIT = 2 #issued when credit is issued, expire
  
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  belongs_to :project
  
end


# == Schema Information
#
# Table name: shares
#
#  id         :integer         not null, primary key
#  amount     :float           not null
#  expires    :datetime
#  variation  :integer         default(2), not null
#  issued_on  :datetime
#  created_on :datetime
#  updated_on :datetime
#  project_id :integer
#  owner_id   :integer
#

