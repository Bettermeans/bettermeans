require 'spec_helper'

describe Issue do

  let(:issue) { Issue.new }

  describe 'associations' do
    it { should belong_to(:project) }
    it { should belong_to(:tracker) }
    it { should belong_to(:status).class_name('IssueStatus') }
    it { should belong_to(:author).class_name('User') }
    it { should belong_to(:assigned_to).class_name('User') }
    it { should belong_to(:retro) }
    it { should belong_to(:hourly_type) }

    it { should have_many(:journals).dependent(:destroy) }
    it { should have_many(:relations_from).class_name('IssueRelation') }
    it { should have_many(:relations_to).class_name('IssueRelation') }
    it { should have_many(:issue_votes).dependent(:delete_all) }
    it { should have_many(:todos).dependent(:delete_all) }
  end

  describe '#is_gift?' do
    context 'when the tracker is a gift' do
      it 'returns true' do
        issue.stub(:tracker).and_return(mock(:gift? => true))
        issue.is_gift?.should be_true
      end
    end

    context 'when the tracker is not a gift' do
      it 'returns false' do
        issue.stub(:tracker).and_return(mock(:gift? => false))
        issue.is_gift?.should be_false
      end
    end
  end

  describe '#is_expense?' do
    context 'when the tracker is an expense' do
      it 'returns true' do
        issue.stub(:tracker).and_return(mock(:expense? => true))
        issue.is_expense?.should be_true
      end
    end

    context 'when the tracker is not an expense' do
      it 'returns false' do
        issue.stub(:tracker).and_return(mock(:expense? => false))
        issue.is_expense?.should be_false
      end
    end
  end

  describe '#is_hourly?' do
    context 'when the tracker is hourly' do
      it 'returns true' do
        issue.stub(:tracker).and_return(mock(:hourly? => true))
        issue.is_hourly?.should be_true
      end
    end

    context 'when the tracker is not hourly' do
      it 'returns false' do
        issue.stub(:tracker).and_return(mock(:hourly? => false))
        issue.is_hourly?.should be_false
      end
    end
  end

end
