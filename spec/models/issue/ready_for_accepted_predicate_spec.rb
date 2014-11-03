require 'spec_helper'

describe Issue, '#ready_for_accepted?' do

  let(:issue) { Issue.new(:points => 5, :accept_total => 1)}

  it 'returns true when the status is accepted' do
    issue.status = IssueStatus.accepted
    issue.ready_for_accepted?.should be true
  end

  it 'return false if points is nil' do
    issue.points = nil
    issue.ready_for_accepted?.should be false
  end

  it 'returns false if accept_total < 0' do
    issue.accept_total = -1
    issue.ready_for_accepted?.should be false
  end

  it 'returns true when accept_total is > 0 and updated more than 3 days ago' do
    issue.updated_at = 4.days.ago
    issue.ready_for_accepted?.should be true
  end

   it 'returns true when accept_total is > 0 and updated less than 3 days ago' do
    issue.updated_at = 2.days.ago
    issue.ready_for_accepted?.should be false
  end
end
