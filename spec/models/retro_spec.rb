require 'spec_helper'

describe Retro do
  it { should belong_to(:project) }
  it { should have_many(:issues) }
  it { should have_many(:journals).through(:issues) }
  it { should have_many(:issue_votes).through(:issues) }
  it { should have_many(:retro_ratings) }
  it { should have_many(:credit_distributions) }

  describe "#set_from_date" do

  end

  describe "#ended?" do
    let(:retro) { Retro.new }

    context "when project status is ended" do
      it "returns true" do
        retro.status_id = Retro::STATUS_COMPLETE || Retro::STATUS_DISTRIBUTED
        retro.should be_ended
      end
    end

    context "when project status is in progress" do
      it "returns false" do
        retro.status_id = Retro::STATUS_INPROGRESS
        retro.should_not be_ended
      end
    end
  end

  describe "#distribute_credits" do

  end

  describe "#close" do

  end
end
