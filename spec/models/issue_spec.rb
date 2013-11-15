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

  describe '#visible?' do
  end

  describe '#ready_fo_open?' do
  end

  describe '#ready_fo_canceled?' do
  end

  describe '#ready_fo_accepted?' do
  end

  describe '#ready_fo_rejected?' do
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

  describe '#is_feature' do
    context 'when tracker is feature' do
      it 'returns true' do
        issue.stub(:tracker).and_return(mock(:feature? => true))
        issue.is_feature.should be_true
      end
    end

    context 'when tracker is not feature' do
      it 'returns false' do
        issue.stub(:tracker).and_return(mock(:feature? => false))
        issue.is_feature.should be_false
      end
    end
  end

  describe '#is_bug' do
    context 'when tracker is bug' do
      it 'returns true' do
        issue.stub(:tracker).and_return(mock(:bug? => true))
        issue.is_bug.should be_true
      end
    end

    context 'when tracker is not bug' do
      it 'returns false' do
        issue.stub(:tracker).and_return(mock(:bug? => false))
        issue.is_bug.should be_false
      end
    end
  end

  describe '#is_chore' do
    context 'when tracker is chore' do
      it 'returns true' do
        issue.stub(:tracker).and_return(mock(:chore? => true))
        issue.is_chore.should be_true
      end
    end

    context 'when tracker is not chore' do
      it 'returns false' do
        issue.stub(:tracker).and_return(mock(:chore? => false))
        issue.is_chore.should be_false
      end
    end
  end

  describe '#updated_status' do
    context 'when ready_for_accepted?' do

    end
  end

  describe '#after_initialize' do
  end

  describe '#has_team?' do
  end

  describe '#has_todos?' do
    context 'when todos exist' do
      it 'returns true' do
        todo = Todo.new(:subject => "string")
        issue = Issue.new
        issue.stub(:todos).and_return([todo])
        issue.has_todos?.should be_true
      end
    end

    context 'when todos do not exist' do
      it 'returns false' do
        issue.stub(:todos).and_return([])
        issue.has_todos?.should be_false
      end
    end
  end

  describe '#team_votes' do
  end

  describe '#team_members' do
  end

end
