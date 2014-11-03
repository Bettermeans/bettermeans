require 'spec_helper'

describe Issue, '#ready_for_rejected?' do

  let(:issue) { Issue.new(:points => 5, :accept_total => -1) }

  it 'returns true if the status is rejected' do
    issue.status = IssueStatus.rejected
    issue.ready_for_rejected?.should be true
  end

  it 'returns false if points is nil' do
    issue.points = nil
    issue.ready_for_rejected?.should be false
  end

  it 'returns false if accept_total >= 0' do
    issue.accept_total = 0
    issue.ready_for_rejected?.should be false
  end

  context 'when accept_total < 0' do
    it 'returns true when updated_at < 3 days ago' do
      issue.updated_at = 4.days.ago
      issue.ready_for_rejected?.should be true
    end

    it 'returns false when updated_at is more recent than 3 days ago' do
      issue.updated_at = 2.days.ago
      issue.ready_for_rejected?.should be false
    end
  end
end
