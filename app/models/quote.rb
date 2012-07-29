class Quote < ActiveRecord::Base
  belongs_to :user

  def self.random
    Quote.find :first, :offset => rand(Quote.count)
  end
end
