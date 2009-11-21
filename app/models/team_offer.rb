class TeamOffer < ActiveRecord::Base
  fields do
    project_id :integer 
    author_id :integer #author of offer/request
    recipient_id :integer #recipient of offer/request
    response :integer, :default => 0 #-1 disabled #0 no response #1 recinded/withdrawn #2 accepted #3 declined
    variation :integer #0 offer #1 request
    expires :datetime, :default =>  Time.now.advance(:months => 1)
  end
  
  # Team offer response
  RESPONSE_DISABLED = -1
  RESPONSE_NONE = 0
  RESPONSE_WITHDRAWN = 1
  RESPONSE_ACCEPTED = 2
  RESPONSE_DECLINED = 3

  # Team offer types
  VARIATION_OFFER = 0
  VARIATION_REQUEST = 1
  
  validates_presence_of :response
  
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  belongs_to :recipient, :class_name => 'User', :foreign_key => 'recipient_id'
  belongs_to :project
  
  def offer?
    variation == VARIATION_OFFER
  end
  
  def request?
    variation == VARIATION_REQUEST
  end
  
  def accepted?
    response = RESPONSE_ACCEPTED
  end
  
  def withdrawn?
    response = RESPONSE_WITHDRAWN
  end
  
  def declined?
    response = RESPONSE_DECLINED
  end
  
  def response?
    response != RESPONSE_NONE
  end
  
  def disabled?
    response = RESPONSE_DISABLED
  end
  
end
