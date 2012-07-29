class IssueVote < ActiveRecord::Base
  belongs_to :user
  belongs_to :issue
  before_create :remove_similar
  before_save :set_binding

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

  def remove_similar
    deleted = IssueVote.delete_all(:issue_id => issue_id, :user_id => user_id, :vote_type => vote_type)

    #log activity for estimate change
    if deleted > 0 && vote_type == ESTIMATE_VOTE_TYPE
      self.issue.save
      LogActivityStreams.write_single_activity_stream(self.user,:name,self.issue,:subject,"changed their estimate for",:issues, 0, nil,{})
    end
  end

  def set_binding
    result = User.find(self.user_id).binding_voter_of?(self.issue.project)
    self.isbinding = result
    return true
  end

end




