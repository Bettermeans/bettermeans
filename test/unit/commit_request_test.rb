require 'test_helper'

class CommitRequestTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end


# == Schema Information
#
# Table name: commit_requests
#
#  id           :integer         not null, primary key
#  user_id      :integer         default(0), not null
#  issue_id     :integer         default(0), not null
#  days         :integer         default(0)
#  responder_id :integer         default(0)
#  response     :integer         default(0), not null
#  created_on   :datetime
#  updated_on   :datetime
#

