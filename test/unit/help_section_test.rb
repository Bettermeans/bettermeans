require 'test_helper'

class HelpSectionTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: help_sections
#
#  id         :integer         not null, primary key
#  user_id    :integer         default(0), not null
#  name       :string(255)
#  show       :boolean         default(TRUE)
#  created_on :datetime
#  updated_on :datetime
#

