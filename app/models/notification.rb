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

  def mark_as_responded
    self.state = STATE_RESPONDED
    self.params = nil
    self.save
  end

  #returns true if notification is of a mention type
  def mention?
    self.variation == "mention"
  end

  # Returns true or false based on if this user has any notifications that haven't been responded to
  def self.unresponded?
    self.unresponded_count > 0 ? true : false
  end

  # Returns the number of unresponded notifications for this user
  def self.unresponded_count
    self.count(:conditions => ["recipient_id=? AND (expiration is null or expiration >=?) AND state = 0", User.current, Time.new.to_date])
  end

  def self.unresponded
    self.find(:all, :conditions => ["recipient_id=? AND (expiration is null or expiration >=?) AND state = 0", User.current, Time.new.to_date])
  end

  def remove_mention_duplicates
    return unless mention?
    Notification.update_all(["state = ?", STATE_ARCHIVED], {:variation => 'mention', :recipient_id => self.recipient_id, :source_id => self.source_id, :source_type => self.source_type})
  end

  # Deactivates all unanswered notifications for a particular variation and source id
  def self.recind(variation, source_id, sender_id)
    Notification.update_all(["state = ?", STATE_RECINDED], {:variation => variation, :sender_id => sender_id, :source_id => source_id, :state => 0})
  end

  # Deactivates all unanswered notifications for a particular variation and source id
  def self.deactivate_all(variation, source_id)
    update_all(variation,source_id,0,STATE_DEACTIVATED)
  end

  def self.activate_all(variation, source_id)
    update_all(variation,source_id,-1,STATE_ACTIVE)
  end
end


