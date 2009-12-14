require 'test_helper'

class TeamOfferTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end


# == Schema Information
#
# Table name: team_offers
#
#  id             :integer         not null, primary key
#  response       :integer         default(0)
#  variation      :integer
#  expires        :datetime
#  recipient_id   :integer
#  project_id     :integer
#  author_id      :integer
#  author_note    :text
#  recipient_note :text
#  created_on     :datetime
#  updated_on     :datetime
#

