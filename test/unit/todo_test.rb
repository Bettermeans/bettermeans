require 'test_helper'

class TodoTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end


# == Schema Information
#
# Table name: todos
#
#  id           :integer         not null, primary key
#  subject      :string(255)
#  author_id    :integer
#  owner_id     :integer
#  issue_id     :integer
#  completed_on :datetime
#  created_on   :datetime
#  updated_on   :datetime
#

