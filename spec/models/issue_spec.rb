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


  describe '#ready_for_open?' do
    let(:issue) { Issue.new(:agree => 2, :disagree => 0, :points => 0, :agree_total => 1)}

    context 'when points are not nil and agree_total exceeds 0' do
      context 'when agree-disagree difference exceeds minimum' do
        it 'returns true' do
          issue.stub(:points_from_credits).and_return 0
          issue.should be_ready_for_open
        end
      end
    end
  end

  describe '#ready_for_canceled?' do
    context 'when agree_total < 0 and updated prior to cutoff date' do
      it 'returns true' do
        cutoff_date = Setting::LAZY_MAJORITY_LENGTH
        issue.agree_total = -1
        issue.updated_at = DateTime.now - cutoff_date - 1
        issue.should be_ready_for_canceled
      end
    end
  end

  describe '#ready_for_accepted?' do
    context 'when IssueStatus is accepted' do
      it 'returns true' do
        issue.status = IssueStatus.accepted
        issue.should be_ready_for_accepted
      end
    end

    context 'when accept_total is < 1 or points are nil' do
      it 'returns false' do
        issue.points = nil
        issue.should_not be_ready_for_accepted
      end
    end

    context 'when accept_total > 0 and updated prior to cutoff date' do
      it 'returns true' do
        cutoff_date = Setting::LAZY_MAJORITY_LENGTH
        issue.accept_total = 5
        issue.points = 1
        issue.updated_at = DateTime.now - cutoff_date - 1
        issue.should be_ready_for_accepted
      end
    end
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
  end

  describe '#after_initialize' do
    context 'when issue is a new record' do
      it 'sets and return default IssueStatus values' do
        issue.status.should == IssueStatus.default
      end
    end
  end

  describe '#has_todos?' do
    context 'when todos exist' do
      it 'returns true' do
        todo = Todo.new(:subject => "string")
        issue = Issue.new
        issue.stub(:todos).and_return([todo])
        issue.should be_has_todos
      end
    end

    context 'when todos do not exist' do
      it 'returns false' do
        issue.stub(:todos).and_return([])
        issue.has_todos?.should be_false
      end
    end
  end

  describe '#dollar_amount' do
    it 'return points' do
      issue.points = 10
      issue.dollar_amount.should == 10
    end
  end

  describe '#after_create' do
    it 'return project details and increase Job count by 1' do
      fake_project = stub()
      fake_project.should_receive(:send_later).with(:refresh_issue_count)
      issue.stub(:project).and_return(fake_project)
      issue.after_create
    end
  end

end
