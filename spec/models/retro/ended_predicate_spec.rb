require 'spec_helper'

describe Retro, '#ended?' do

  let(:retro) { Retro.new }

  context "when project status is ended" do
    it "returns true" do
      retro.status_id = Retro::STATUS_COMPLETE
      retro.ended?.should be true
    end
  end

  context "when project status is distributed" do
    it "returns true" do
      retro.status_id = Retro::STATUS_DISTRIBUTED
      retro.ended?.should be true
    end
  end

  context "when project status is in progress" do
    it "returns false" do
      retro.status_id = Retro::STATUS_INPROGRESS
      retro.ended?.should be false
    end
  end

end
