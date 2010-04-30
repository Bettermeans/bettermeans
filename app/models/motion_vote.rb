class MotionVote < ActiveRecord::Base
  belongs_to :user
  belongs_to :motion
  before_create :remove_similar_votes
  before_save :set_binding
  
  def project
    motion.project
  end
  
  def remove_similar_votes
    IssueVote.delete_all(:motion_id => motion_id, :user_id => user_id)
  end
  
  def set_binding
    self.isbinding = self.user.binding_voter_of?(self.project)
    return true
  end
end


# == Schema Information
#
# Table name: motion_votes
#
#  id         :integer         not null, primary key
#  motion_id  :integer
#  user_id    :integer
#  points     :integer
#  isbinding  :boolean         default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

