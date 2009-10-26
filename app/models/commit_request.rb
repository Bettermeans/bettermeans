class CommitRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :issue  
    
  acts_as_activity_provider :find_options => {:include => [:project, :issue]},
                            :author_key => :user_id
  
  #True if user has requested commitment to this ussue
  def self.committed?(user, issue)
    ! (find(:first, :conditions => ["user_id = ? AND issue_id = ?", user, issue]) == nil)
  end

  #Returns request for current user and issue
  def self.request(user, issue, userowned)
    if (userowned) #user owns this issue, we're looking for the commit request that he took this issue with (either accepting an offer, taking one)
      @cr = find(:first, :conditions => ["responder_id = ? AND issue_id = ? AND (response = 2 or response = 6) ", user, issue], :order => "updated_on DESC")
    else
      @cr = find(:first, :conditions => ["user_id = ? AND issue_id = ?", user, issue], :order => "updated_on DESC")
    end
  end
  
end
