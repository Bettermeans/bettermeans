class Quote < ActiveRecord::Base
  belongs_to :user
  def self.random

    Quote.find :first, :offset => rand(Quote.count)
    # rand_id = rand(max_id)
    # # find the first widget with an id equal to or greater than rand_id
    # first(:conditions => "id >= #{rand_id}") || last

    # rand_id = rand(Quote.count)
    #     rand_record = Quote.first(:conditions => [ "id >= ?", rand_id]) # don't use OFFSET on MySQL; it's very slow
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
#  created_at :datetime
#  updated_at :datetime
#

