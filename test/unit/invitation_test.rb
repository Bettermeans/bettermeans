require 'test_helper'

class InvitationTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end




# == Schema Information
#
# Table name: invitations
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  project_id :integer
#  token      :string(255)
#  status     :integer         default(0)
#  role_id    :integer
#  mail       :string(255)
#  created_on :datetime
#  updated_on :datetime
#

