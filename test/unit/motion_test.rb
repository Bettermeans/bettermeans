require 'test_helper'

class MotionTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end



# == Schema Information
#
# Table name: motions
#
#  id          :integer         not null, primary key
#  project_id  :integer
#  title       :string(255)
#  description :text
#  variation   :string(255)
#  params      :text
#  motion_type :integer
#  state       :integer
#  created_at  :datetime
#  updated_at  :datetime
#

