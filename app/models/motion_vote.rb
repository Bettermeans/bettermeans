class MotionVote < ActiveRecord::Base
  belongs_to :user
  belongs_to :motion
  before_create :remove_similar_votes
  before_save :set_binding
  after_save :update_agree_total, :remove_notifications

  named_scope :belong_to_user, lambda {|user_id| {:conditions => {:user_id => user_id}} }

  named_scope :history, :order => 'updated_at DESC', :include => :user

  def project # spec_me cover_me heckle_me
    self.motion.project
  end

  def remove_similar_votes # spec_me cover_me heckle_me
    MotionVote.delete_all(:motion_id => motion_id, :user_id => user_id)
  end

  def set_binding # spec_me cover_me heckle_me
    self.isbinding = self.user.binding_voter_of_motion?(self.motion)
    return true
  end

  def action_description # spec_me cover_me heckle_me
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

  def update_agree_total # spec_me cover_me heckle_me
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

  def remove_notifications # spec_me cover_me heckle_me
    Notification.update_all "state = #{Notification::STATE_ARCHIVED}" , ["variation = 'motion_started' AND source_id = ? AND recipient_id = ?", self.motion_id, self.user_id]
  end


end

