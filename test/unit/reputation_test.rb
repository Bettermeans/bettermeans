require 'test_helper'

class ReputationTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: reputations
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  project_id      :integer
#  reputation_type :integer
#  value           :float
#  params          :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

