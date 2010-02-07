class IssueVote < ActiveRecord::Base
  belongs_to :user
  belongs_to :issue
  before_create :remove_similar_estimates
  # after_create :update_issue_totals
  # after_update :update_issue_totals
  # after_destroy :update_issue_totals
  
  AGREE_VOTE_TYPE = 1
  ACCEPT_VOTE_TYPE = 2
  PRI_VOTE_TYPE = 3
  ESTIMATE_VOTE_TYPE = 4
  JOIN_VOTE_TYPE = 5 # Not exactly a vote, but used to join the team that's working on an issue
  
  def update_issue_totals
    case vote_type
      when AGREE_VOTE_TYPE
        issue.update_agree_total
      when ACCEPT_VOTE_TYPE
        issue.update_accept_total
      when PRI_VOTE_TYPE
        issue.update_pri_total
      when ESTIMATE_VOTE_TYPE
        issue.update_estimate_total
      end
  end
  
  def remove_similar_estimates
    IssueVote.delete_all(:issue_id => issue_id, :user_id => user_id, :vote_type => vote_type)
  end
  
end

# == Schema Information
#
# Table name: issue_votes
#
#  id         :integer         not null, primary key
#  points     :integer         not null
#  user_id    :integer         not null
#  issue_id   :integer         not null
#  vote_type  :integer         not null
#  created_on :datetime
#  updated_on :datetime
#

