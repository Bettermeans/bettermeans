require 'test_helper'

class RetroRatingTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end


# == Schema Information
#
# Table name: retro_ratings
#
#  id         :integer         not null, primary key
#  rater_id   :integer
#  ratee_id   :integer
#  score      :float
#  retro_id   :integer
#  created_at :datetime
#  updated_at :datetime
#  confidence :integer         default(100)
#

