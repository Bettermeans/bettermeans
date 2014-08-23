require 'spec_helper'

describe Tracker, '#issue_statuses' do

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
