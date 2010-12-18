require 'spec_helper'

describe Hash do
  describe "to_array_conditions" do
    it "should load individual values" do
      {:v1 => 1, :v2 => '2'}.to_array_conditions.should == ["v1 = ? AND v2 = ?",'1','2']
    end

    it "should use in for array values" do
      {:v1 => 1, :v2 => [2,'two']}.to_array_conditions.should ==
        ["v1 = ? AND v2 in (?)", '1', [2,'two']]
    end
  end
end
