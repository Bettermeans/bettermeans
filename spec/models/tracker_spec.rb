require 'spec_helper'

describe Tracker do

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
    let(:tracker) { Tracker.new(:name => "great_name") }
    it 'returns stringified object' do
      tracker.to_s.should == "great_name"
    end
  end

  describe '#gift?' do
    let(:tracker) { Tracker.new(:name => "Gift")}
    it 'returns associated text in the en.yml file' do
      tracker.should be_gift
    end
  end

  describe '#expense?' do
    let(:tracker) { Tracker.new(:name => "Expense")}
    it 'returns associated text in the en.yml file' do
      tracker.should be_expense
    end
  end

  describe '#recurring?' do
    let(:tracker) { Tracker.new(:name => "Recurring")}
    it 'returns associated text in the en.yml file' do
      tracker.should be_recurring
    end
  end

  describe '#hourly?' do
    let(:tracker) { Tracker.new(:name => "Hourly")}
    it 'returns associated text in the en.yml file' do
      tracker.should be_hourly
    end
  end

  describe '#feature?' do
    let(:tracker) { Tracker.new(:name => "Feature")}
    it 'returns associated text in the en.yml file' do
      tracker.should be_feature
    end
  end

  describe '#bug?' do
    let(:tracker) { Tracker.new(:name => "Bug")}
    it 'returns associated text in the en.yml file' do
      tracker.should be_bug
    end
  end

  describe '#chore?' do
    let(:tracker) { Tracker.new(:name => "Chore")}
    it 'returns associated text in the en.yml file' do
      tracker.should be_chore
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
