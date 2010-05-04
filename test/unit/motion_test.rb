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
#  id                  :integer         not null, primary key
#  project_id          :integer
#  title               :string(255)
#  description         :text
#  params              :text
#  variation           :integer         default(0)
#  motion_type         :integer         default(2)
#  visibility_level    :integer         default(5)
#  binding_level       :integer         default(5)
#  state               :integer         default(0)
#  created_at          :datetime
#  updated_at          :datetime
#  ends_on             :date
#  topic_id            :integer
#  author_id           :integer
#  agree               :integer         default(0)
#  disagree            :integer         default(0)
#  agree_total         :integer         default(0)
#  agree_nonbind       :integer         default(0)
#  disagree_nonbind    :integer         default(0)
#  agree_total_nonbind :integer         default(0)
#  concerned_user_id   :integer
#

