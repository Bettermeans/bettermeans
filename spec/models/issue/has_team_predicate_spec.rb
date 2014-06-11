require 'spec_helper'

describe Issue, '#has_team?' do

  context 'when more than one person joined the issue' do
    it 'returns true' do
      user1 = Factory.create(:user)
      user2 = Factory.create(:user)
      issue = Factory.create(:issue)
      team_votes1 = IssueVote.create!(:vote_type => IssueVote::JOIN_VOTE_TYPE, :issue => issue, :user => user1, :points => 2)
      team_votes2 = IssueVote.create!(:vote_type => IssueVote::JOIN_VOTE_TYPE, :issue => issue, :user => user2, :points => 3)
      issue.has_team?.should be true
    end
  end

end
