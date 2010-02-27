require 'test_helper'

class IssueVoteTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end





# == Schema Information
#
# Table name: issue_votes
#
#  id         :integer         not null, primary key
#  points     :float           not null
#  user_id    :integer         not null
#  issue_id   :integer         not null
#  vote_type  :integer         not null
#  created_on :datetime
#  updated_on :datetime
#  isbinding  :boolean         default(FALSE)
#

