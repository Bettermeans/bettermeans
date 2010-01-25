class Retro < ActiveRecord::Base
  
  #Constants
  STATUS_NOTSTARTED = 0
  STATUS_INPROGRESS = 1
  STATUS_COMPLETE = 2
  STATUS_INDISPUTE = 3
  
  belongs_to :project
  has_many :issues
end



# == Schema Information
#
# Table name: retros
#
#  id         :integer         not null, primary key
#  status_id  :integer
#  project_id :integer
#  from_date  :datetime
#  to_date    :datetime
#  created_on :datetime
#  updated_on :datetime
#

