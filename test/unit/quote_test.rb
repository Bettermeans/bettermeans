require 'test_helper'

class QuoteTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: quotes
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  author     :string(255)
#  body       :text
#  created_on :datetime
#  updated_on :datetime
#

