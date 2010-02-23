require 'test_helper'

class CreditDistributionTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: credit_distributions
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  project_id :integer
#  retro_id   :integer
#  amount     :float
#  created_on :datetime
#  updated_on :datetime
#

