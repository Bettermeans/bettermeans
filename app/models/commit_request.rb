class CommitRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :issue
  
  #True if user has requested commitment to this ussue
  def self.committed?(user, issue)
    ! (find(:first, :conditions => ["user_id = ? AND issue_id = ?", user, issue]) == nil)
  end
  
  def self.request_id(user, issue)
    @cr = find(:first, :conditions => ["user_id = ? AND issue_id = ?", user, issue])
    unless (@cr == nil)
      @cr.id
    else
      nil
    end    
  end
  
end
