require 'test_helper'

class MotionVoteTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: motion_votes
#
#  id         :integer         not null, primary key
#  motion_id  :integer
#  user_id    :integer
#  points     :integer
#  isbinding  :boolean
#  created_at :datetime
#  updated_at :datetime
#

