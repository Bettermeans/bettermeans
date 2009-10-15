class CommitRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :issue
  
  #True if user has requested commitment to this ussue
  def self.committed?(user, issue)
    ! (find(:first, :conditions => ["user_id = ? AND issue_id = ?", user, issue]) == nil)
  end

  #Returns request for current user and issue
  def self.request(user, issue)
    @cr = find(:first, :conditions => ["user_id = ? AND issue_id = ?", user, issue], :order => "updated_on DESC")
  end
  
end
