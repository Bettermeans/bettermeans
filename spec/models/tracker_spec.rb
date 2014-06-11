require 'spec_helper'

describe Tracker do
  let(:tracker) { Tracker.new }

  describe 'associations' do
    it { should have_many(:issues) }
    it { should have_many(:workflows) }

    it { should have_many(:projects_trackers) }
    it { should have_many(:projects).through(:projects_trackers) }
  end

  describe '#valid?' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe '#to_s' do
    it 'returns stringified object' do
      tracker.name = 'pie'
      tracker.to_s.should == "pie"
    end
  end

  describe '#gift?' do
    context 'when the name is Gift' do
      it 'returns true' do
        tracker.name = 'Gift'
        tracker.gift?.should be true
      end
    end

    context 'when the name is not Gift' do
      it 'returns false' do
        tracker.name = 'not_gift'
        tracker.gift?.should be false
      end
    end
  end

  describe '#expense?' do
    context 'when the name is Expense' do
      it 'returns true' do
        tracker.name = 'Expense'
        tracker.expense?.should be true
      end
    end

    context 'when the name is not Expense' do
      it 'returns false' do
        tracker.name = 'not_expense'
        tracker.expense?.should be false
      end
    end
  end

  describe '#recurring?' do
    context 'when the name is Recurring' do
      it 'returns true' do
        tracker.name = 'Recurring'
        tracker.recurring?.should be true
      end
    end

    context 'when the name is not Recurring' do
      it 'returns false' do
        tracker.name = 'not_recurring'
        tracker.recurring?.should be false
      end
    end
  end

  describe '#hourly?' do
    context 'when the name is Hourly' do
      it 'returns true' do
        tracker.name = 'Hourly'
        tracker.hourly?.should be true
      end
    end

    context 'when the name is not Hourly' do
      it 'returns true' do
        tracker.name = 'not_hourly'
        tracker.hourly?.should be false
      end
    end
  end

  describe '#feature?' do
    context 'when the name is Feature' do
      it 'returns true' do
        tracker.name = 'Feature'
        tracker.feature?.should be true
      end
    end

    context 'when the name is not Feature' do
      it 'returns false' do
        tracker.name = 'not_feature'
        tracker.feature?.should be false
      end
    end
  end

  describe '#bug?' do
    context 'when the name is Bug' do
      it 'returns true' do
        tracker.name = 'Bug'
        tracker.bug?.should be true
      end
    end

    context 'when the name is not Bug' do
      it 'returns false' do
        tracker.name = 'not_bug'
        tracker.bug?.should be false
      end
    end
  end

  describe '#chore?' do
    context 'when the name is Chore' do
      it 'returns true' do
        tracker.name = 'Chore'
        tracker.chore?.should be true
      end
    end

    context 'when the name is not Chore' do
      it 'returns false' do
        tracker.name = 'not_chore'
        tracker.chore?.should be false
      end
    end
  end

  describe '#issue_statuses' do
    let(:tracker) { Tracker.new(:name => "Feature") }

    context "when issue_status exists" do
      it "returns an array of issue statuses" do
        tracker.instance_variable_set(:@issue_statuses, ['stuff', 'moreStuff'])
        tracker.issue_statuses.should == ['stuff', 'moreStuff']
      end
    end

    context "when issue_status does not exist" do
      it "returns an empty array" do
        tracker.issue_statuses.should == []
      end
    end
  end
end
