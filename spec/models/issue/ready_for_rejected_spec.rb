require 'spec_helper'

describe Issue, '#ready_for_rejected?' do

  let(:issue) { Issue.new }

  context 'when IssueStatus is rejected' do
    it 'returns true' do
      issue.status = IssueStatus.rejected
      issue.should be_ready_for_rejected
    end
  end

end
