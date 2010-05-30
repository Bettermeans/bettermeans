require 'test_helper'

class HourlyTypeTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end



# == Schema Information
#
# Table name: hourly_types
#
#  id                     :integer         not null, primary key
#  project_id             :integer
#  name                   :string(255)
#  hourly_rate_per_person :decimal(8, 2)
#  hourly_cap             :decimal(8, 2)
#  created_at             :datetime
#  updated_at             :datetime
#

