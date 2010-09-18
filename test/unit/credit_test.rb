require 'test_helper'

class CreditTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: credits
#
#  id         :integer         not null, primary key
#  amount     :float           not null
#  issued_on  :datetime
#  created_at :datetime
#  updated_at :datetime
#  owner_id   :integer
#  project_id :integer
#  settled_on :datetime
#  enabled    :boolean         default(TRUE)
#

