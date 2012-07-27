class Quote < ActiveRecord::Base
  belongs_to :user

  def self.random
    Quote.find :first, :offset => rand(Quote.count)
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

