require 'spec_helper'

describe Issue, '#team_votes' do

  it 'returns issues_votes of vote_type JOIN_VOTE_TYPE' do
    user = Factory.create(:user)
    issue = Factory.create(:issue)
    agree_vote = IssueVote.create!(:vote_type => IssueVote::AGREE_VOTE_TYPE, :issue => issue, :user => user, :points => 2)
    join_vote = IssueVote.create!(:vote_type => IssueVote::JOIN_VOTE_TYPE, :issue => issue, :user => user, :points => 3)
    issue.team_votes.should == [join_vote]
  end

end
