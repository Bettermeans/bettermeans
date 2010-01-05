require 'test_helper'

class EstimateTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: estimates
#
#  id         :integer         not null, primary key
#  points     :integer         not null
#  user_id    :integer         not null
#  issue_id   :integer         not null
#  created_on :datetime
#  updated_on :datetime
#

