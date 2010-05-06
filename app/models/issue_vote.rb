class IssueVote < ActiveRecord::Base
  belongs_to :user
  belongs_to :issue
  before_create :remove_similar_estimates
  before_save :set_binding
  # after_create :update_issue_totals
  # after_update :update_issue_totals
  # after_destroy :update_issue_totals
  
  AGREE_VOTE_TYPE = 1
  ACCEPT_VOTE_TYPE = 2
  PRI_VOTE_TYPE = 3
  ESTIMATE_VOTE_TYPE = 4
  JOIN_VOTE_TYPE = 5 # Not exactly a vote, but used to join the team that's working on an issue
  
  def project
    issue.project
  end
  
  def update_issue_totals
    case vote_type
      when AGREE_VOTE_TYPE
        issue.update_agree_total self.isbinding
      when ACCEPT_VOTE_TYPE
        issue.update_accept_total self.isbinding
      when PRI_VOTE_TYPE
        issue.update_pri_total self.isbinding
      when ESTIMATE_VOTE_TYPE
        issue.update_estimate_total self.isbinding
      end
  end
  
  def remove_similar_estimates
    IssueVote.delete_all(:issue_id => issue_id, :user_id => user_id, :vote_type => vote_type)
  end
  
  def set_binding
    result = self.user.binding_voter_of?(self.issue.project)
    self.isbinding = result
    return true
  end
  
end





# == Schema Information
#
# Table name: issue_votes
#
#  id         :integer         not null, primary key
#  points     :float           not null
#  user_id    :integer         not null
#  issue_id   :integer         not null
#  vote_type  :integer         not null
#  created_on :datetime
#  updated_on :datetime
#  isbinding  :boolean         default(FALSE)
#

