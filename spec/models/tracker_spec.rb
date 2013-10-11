require 'spec_helper'

describe Tracker do
  let(:tracker) { Tracker.new }

  describe 'associations' do
    it { should have_many(:issues) }
    it { should have_many(:workflows) }

    it { should have_and_belong_to_many(:projects) }
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
        tracker.should be_gift
      end
    end

    context 'when the name is not Gift' do
      it 'returns false' do
        tracker.name = 'not_gift'
        tracker.should_not be_gift
      end
    end
  end

  describe '#expense?' do
    context 'when the name is Expense' do
      it 'returns true' do
        tracker.name = 'Expense'
        tracker.should be_expense
      end
    end

    context 'when the name is not Expense' do
      it 'returns false' do
        tracker.name = 'not_expense'
        tracker.should_not be_expense
      end
    end
  end

  describe '#recurring?' do
    context 'when the name is Recurring' do
      it 'returns true' do
        tracker.name = 'Recurring'
        tracker.should be_recurring
      end
    end

    context 'when the name is not Recurring' do
      it 'returns false' do
        tracker.name = 'not_recurring'
        tracker.should_not be_recurring
      end
    end
  end

  describe '#hourly?' do
    context 'when the name is Hourly' do
      it 'returns true' do
        tracker.name = 'Hourly'
        tracker.should be_hourly
      end
    end

    context 'when the name is not Hourly' do
      it 'returns true' do
        tracker.name = 'not_hourly'
        tracker.should_not be_hourly
      end
    end
  end

  describe '#feature?' do
    context 'when the name is Feature' do
      it 'returns true' do
        tracker.name = 'Feature'
        tracker.should be_feature
      end
    end

    context 'when the name is not Feature' do
      it 'returns false' do
        tracker.name = 'not_feature'
        tracker.should_not be_feature
      end
    end
  end

  describe '#bug?' do
    context 'when the name is Bug' do
      it 'returns true' do
        tracker.name = 'Bug'
        tracker.should be_bug
      end
    end

    context 'when the name is not Bug' do
      it 'returns false' do
        tracker.name = 'not_bug'
        tracker.should_not be_bug
      end
    end
  end

  describe '#chore?' do
    context 'when the name is Chore' do
      it 'returns true' do
        tracker.name = 'Chore'
        tracker.should be_chore
      end
    end

    context 'when the name is not Chore' do
      it 'returns false' do
        tracker.name = 'not_chore'
        tracker.should_not be_chore
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
