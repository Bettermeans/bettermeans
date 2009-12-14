class Credit < ActiveRecord::Base
  default_value_for :issued_on do
    Time.now
  end
  
  
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  belongs_to :project
  
end




# == Schema Information
#
# Table name: credits
#
#  id         :integer         not null, primary key
#  amount     :float           not null
#  issued_on  :datetime
#  created_on :datetime
#  updated_on :datetime
#  owner_id   :integer
#  project_id :integer
#

