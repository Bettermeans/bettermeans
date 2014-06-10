require 'spec_helper'

describe Issue, '#team_members' do

  it 'returns issue_votes of given conditions and maps to user' do
    user = Factory.create(:user)
    issue = Factory.create(:issue)
    IssueVote.create!(:vote_type => IssueVote::AGREE_VOTE_TYPE, :issue => issue, :user => user, :points => 2)
    IssueVote.create!(:vote_type => IssueVote::JOIN_VOTE_TYPE, :issue => issue, :user => user, :points => 3)
    issue.team_members.should == [user]
  end

end
