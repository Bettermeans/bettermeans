require 'spec_helper'

describe Issue, '#ready_for_rejected?' do

  let(:issue) { Issue.new }

  context 'when IssueStatus is rejected' do
    it 'returns true' do
      issue.status = IssueStatus.rejected
      issue.ready_for_rejected?.should be true
    end
  end

end
