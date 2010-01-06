class Quote < ActiveRecord::Base
  def self.random
    rand_id = rand(Quote.count)
    rand_record = Quote.first(:conditions => [ "id >= ?", rand_id]) # don't use OFFSET on MySQL; it's very slow
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

