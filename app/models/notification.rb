class Notification < ActiveRecord::Base
  serialize :params

  belongs_to :recipient, :class_name => 'User', :foreign_key => 'recipient_id'
  belongs_to :sender, :class_name => 'User', :foreign_key => 'sender_id'

  # Returns all active, non responded, non-expired notifications
  named_scope :allactive, :conditions => ["state = 0 AND (expiration is null or expiration >=?)", Time.new.to_date]

  before_create :remove_mention_duplicates

  STATE_DEACTIVATED = -1
  STATE_ACTIVE = 0
  STATE_RESPONDED = 1
  STATE_ARCHIVED = 2
  STATE_RECINDED = 3

  def mark_as_responded # spec_me cover_me heckle_me
    self.state = STATE_RESPONDED
    self.params = nil
    self.save
  end

  #returns true if notification is of a mention type
  def mention? # spec_me cover_me heckle_me
    self.variation == "mention"
  end

  # Returns true or false based on if this user has any notifications that haven't been responded to
  def self.unresponded? # spec_me cover_me heckle_me
    self.unresponded_count > 0 ? true : false
  end

  # Returns the number of unresponded notifications for this user
  def self.unresponded_count # spec_me cover_me heckle_me
    self.count(:conditions => ["recipient_id=? AND (expiration is null or expiration >=?) AND state = 0", User.current, Time.new.to_date])
  end

  def self.unresponded # spec_me cover_me heckle_me
    self.find(:all, :conditions => ["recipient_id=? AND (expiration is null or expiration >=?) AND state = 0", User.current, Time.new.to_date])
  end

  def remove_mention_duplicates # spec_me cover_me heckle_me
    return unless mention?
    Notification.update_all(["state = ?", STATE_ARCHIVED], {:variation => 'mention', :recipient_id => self.recipient_id, :source_id => self.source_id, :source_type => self.source_type})
  end

  # Deactivates all unanswered notifications for a particular variation and source id
  def self.recind(variation, source_id, sender_id) # heckle_me
    Notification.update_all(["state = ?", STATE_RECINDED], {:variation => variation, :sender_id => sender_id, :source_id => source_id, :state => 0})
  end
end


