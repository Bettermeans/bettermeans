require 'spec_helper'

describe Hash do
  describe "#to_array_conditions" do
    it "should load individual values" do
      hash = {:v1 => 1, :v2 => '2'}

      possible_results = [
        ["v1 = ? AND v2 = ?",'1','2'],
        ["v2 = ? AND v1 = ?",'2','1'],
      ]

      possible_results.should include(hash.to_array_conditions)
    end

    it "should use in for array values" do
      hash = {:v1 => 1, :v2 => [2,'two']}

      possible_results = [
        ["v1 = ? AND v2 in (?)", '1', [2,'two']],
        ["v2 in (?) AND v1 = ?", [2,'two'], '1'],
      ]

      possible_results.should include(hash.to_array_conditions)
    end
  end
end
