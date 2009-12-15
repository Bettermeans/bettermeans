require 'test_helper'

class EnterpriseTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end


# == Schema Information
#
# Table name: enterprises
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  description :text
#  homepage    :string(255)     default("")
#  created_at  :datetime
#  updated_at  :datetime
#

