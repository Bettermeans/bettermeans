require 'test_helper'

class RetroTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end




# == Schema Information
#
# Table name: retros
#
#  id           :integer         not null, primary key
#  status_id    :integer
#  project_id   :integer
#  from_date    :datetime
#  to_date      :datetime
#  created_on   :datetime
#  updated_on   :datetime
#  total_points :integer
#

