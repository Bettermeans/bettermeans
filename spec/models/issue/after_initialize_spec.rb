require 'spec_helper'

describe Issue, '#after_initialize' do

  let(:issue) { Issue.new }

  context 'when issue is a new record' do
    it 'sets and return default IssueStatus values' do
      issue.status.should == IssueStatus.default
    end
  end

end
