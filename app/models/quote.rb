class Quote < ActiveRecord::Base
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

