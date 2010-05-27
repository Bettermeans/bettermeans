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
#  id          :integer         not null, primary key
#  project_id  :integer
#  name        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

