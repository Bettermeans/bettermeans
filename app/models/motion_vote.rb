class MotionVote < ActiveRecord::Base
  belongs_to :user
  belongs_to :motion
  before_create :remove_similar_votes
  before_save :set_binding
  after_save :update_agree_total, :remove_notifications

  named_scope :belong_to_user, lambda {|user_id| {:conditions => {:user_id => user_id}} } do
    def default
      find(:first, :conditions => { :is_default => true })
    end
  end


  named_scope :history, :order => 'updated_at DESC', :include => :user

  def project
    self.motion.project
  end

  def remove_similar_votes
    MotionVote.delete_all(:motion_id => motion_id, :user_id => user_id)
  end

  def set_binding
    self.isbinding = self.user.binding_voter_of_motion?(self.motion)
    return true
  end

  def action_description
    if self.motion.motion_type == Motion::TYPE_SHARE
      if (self.points < 0)
        l("label_motion_vote_action_share_disagree",:points => self.points * -1 )
      elsif (self.points == 0)
        l("label_motion_vote_action_share_neutral",:points => self.points)
      else
        l("label_motion_vote_action_share_agree",:points => self.points)
      end
    else
      l("label_motion_vote_action#{self.points + 10000}")
    end
  end

  def update_agree_total
    @motion = self.motion
    if self.isbinding
      @motion.agree =   MotionVote.sum(:points, :conditions => "motion_id = '#{@motion.id}' AND points > 0 AND isbinding='true'")
      @motion.disagree =   MotionVote.sum(:points, :conditions => "motion_id = '#{@motion.id}' AND points < 0 AND isbinding='true'") * -1
      @motion.agree_total = @motion.agree - @motion.disagree
    else
      @motion.agree_nonbind =   MotionVote.sum(:points, :conditions => "motion_id = '#{@motion.id}' AND points > 0 AND isbinding='false'")
      @motion.disagree_nonbind =   MotionVote.sum(:points, :conditions => "motion_id = '#{@motion.id}' AND points < 0 AND isbinding='false'") * -1
      @motion.agree_total_nonbind = @motion.agree_nonbind - @motion.disagree_nonbind
    end
    @motion.save
  end

  def remove_notifications
    Notification.update_all "state = #{Notification::STATE_ARCHIVED}" , ["variation = 'motion_started' AND source_id = ? AND recipient_id = ?", self.motion_id, self.user_id]
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

