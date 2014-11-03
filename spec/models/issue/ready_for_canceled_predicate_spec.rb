require 'spec_helper'

describe Issue, '#ready_for_canceled?' do

  let(:issue) { Issue.new }

  it 'returns false when agree_total > 0' do
    issue.agree_total = 1
    issue.ready_for_canceled?.should be false
  end

  it 'returns false when agree_total == 0' do
    issue.agree_total = 0
    issue.ready_for_canceled?.should be false
  end

  context 'when agree_total < 0' do
    before(:each) { issue.agree_total = -1 }

    it 'returns false when updated_at is more recent than 3 days ago' do
      issue.updated_at = 2.days.ago
      issue.ready_for_canceled?.should be false
    end

    it 'returns true when updated_at is older than 3 days ago' do
      issue.updated_at = 4.days.ago
      issue.ready_for_canceled?.should be true
    end
  end

end
