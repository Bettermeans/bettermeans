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
end
