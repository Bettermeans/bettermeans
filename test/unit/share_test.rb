require 'test_helper'

class ShareTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: shares
#
#  id         :integer         not null, primary key
#  amount     :float           not null
#  expires    :datetime
#  variation  :integer         default(2), not null
#  issued_on  :datetime
#  created_at :datetime
#  updated_at :datetime
#  project_id :integer
#  owner_id   :integer
#

