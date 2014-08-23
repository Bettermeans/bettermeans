require 'spec_helper'

describe Issue, '#updated_status' do

  let(:issue) { Issue.new }

  context 'when status is ready_for_accepted?' do
    it "returns IssueStatus.accepted" do
      issue.stub(:ready_for_accepted?).and_return true
      issue.updated_status.should == IssueStatus.accepted
    end
  end

  context 'when status is ready_for_rejected?' do
    it 'returns IssueStatus.rejected' do
      issue.stub(:ready_for_rejected?).and_return true
      issue.updated_status.should == IssueStatus.rejected
    end
  end

  context 'when status is ready_for_open?' do
    it 'returns IssueStatus.canceled' do
      issue.stub(:ready_for_canceled?).and_return true
      issue.updated_status.should == IssueStatus.canceled
    end
  end

end
