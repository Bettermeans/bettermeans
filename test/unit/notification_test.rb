require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end


# == Schema Information
#
# Table name: notifications
#
#  id           :integer         not null, primary key
#  recipient_id :integer
#  variation    :string(255)
#  params       :text
#  state        :integer         default(0)
#  source_id    :integer
#  expiration   :datetime
#  created_on   :datetime
#  updated_on   :datetime
#

