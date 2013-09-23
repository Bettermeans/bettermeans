class Quote < ActiveRecord::Base
  belongs_to :user

  def self.random # spec_me cover_me heckle_me
    Quote.find :first, :offset => rand(Quote.count)
  end
end
