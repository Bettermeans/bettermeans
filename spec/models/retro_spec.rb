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

  end

  describe "#distribute_credits" do

  end

  describe "#close" do

  end
end
