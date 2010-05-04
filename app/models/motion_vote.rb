class MotionVote < ActiveRecord::Base
  belongs_to :user
  belongs_to :motion
  before_create :remove_similar_votes
  before_save :set_binding
  
  named_scope :belong_to_current_user, :conditions => {:user_id => User.current}
  
  
  def project
    self.motion.project
  end
  
  def remove_similar_votes
    MotionVote.delete_all(:motion_id => motion_id, :user_id => user_id)
  end
  
  def set_binding
    logger.info("self motion : #{self.motion}")
    self.isbinding = self.user.binding_voter_of_motion?(self.motion)
    return true
  end
  
  def action_description
    l ("label_motion_vote_action#{self.points + 10000}")
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

