require 'test_helper'

class TeamPointTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end


# == Schema Information
#
# Table name: team_points
#
#  id           :integer         not null, primary key
#  project_id   :integer
#  author_id    :integer
#  recipient_id :integer
#  created_on   :datetime
#  updated_on   :datetime
#  value        :integer         default(1)
#

