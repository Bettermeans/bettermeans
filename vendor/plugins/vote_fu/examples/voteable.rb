class Voteable < ActiveRecord::Base

  belongs_to :user
  
  acts_as_voteable
  
  named_scope :descending, :order => "created_at DESC"

  
end