require 'spec_helper'

describe Tracker do
  it { should have_many(:issues) }
  it { should have_many(:workflows) }
  it { should have_and_belong_to_many(:projects) }
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }

  describe '#to_s' do
    let(:tracker) { Tracker.new(:name => "great_name") }
    it 'returns stringified object' do
      tracker.to_s.should == "great_name"
    end
  end

  describe '#gift?' do
    let(:tracker) { Tracker.new(:name => "Gift")}
    it 'returns associated text in the en.yml file' do
      tracker.to_s.should == "Gift"
    end
  end

  describe '#expense?' do
    let(:tracker) { Tracker.new(:name => "Expense")}
    it 'returns associated text in the en.yml file' do
      tracker.to_s.should == "Expense"
    end
  end

  describe '#recurring?' do
    let(:tracker) { Tracker.new(:name => "Recurring")}
    it 'returns associated text in the en.yml file' do
      tracker.to_s.should == "Recurring"
    end
  end

  describe '#hourly?' do
    let(:tracker) { Tracker.new(:name => "Hourly")}
    it 'returns associated text in the en.yml file' do
      tracker.to_s.should == "Hourly"
    end
  end

  describe '#feature?' do
    let(:tracker) { Tracker.new(:name => "Feature")}
    it 'returns associated text in the en.yml file' do
      tracker.to_s.should == "Feature"
    end
  end

  describe '#bug?' do
    let(:tracker) { Tracker.new(:name => "Bug")}
    it 'returns associated text in the en.yml file' do
      tracker.to_s.should == "Bug"
    end
  end

  describe '#chore?' do
    let(:tracker) { Tracker.new(:name => "Chore")}
    it 'returns associated text in the en.yml file' do
      tracker.to_s.should == "Chore"
    end
  end

  describe '#issue_statuses' do
    let(:issue) { Issue.new(:id => 10) }
    it 'returns an array of IssueStatus thta are used' do

    end
  end
end
