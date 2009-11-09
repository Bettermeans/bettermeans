class Notification < ActiveRecord::Base
  belongs_to :recipient, :class_name => 'User', :foreign_key => 'recipient_id'  
  
  # Returns true or false based on if this user has any notifications that haven't been responded to
  def self.unresponded?
    self.unresponded_count > 0 ? true : false    
  end
  
  # Returns the number of unresponded notifications for this user
  def self.unresponded_count
    self.count(:conditions => ["recipient_id = ? AND state = 0", User.current])
  end
  
  # Returns all active, non responded, non-expired notifications for current user
  def self.active
    self.find(:all, :conditions => ["recipient_id=? AND (expiration_date is null or expiration_date >=?) AND state = 0", User.current.id, Time.new.to_date])
  end
  
  # Returns all active, non responded, non-expired notifications
  def self.allactive
    self.find(:all, :conditions => ["state = 0 AND (expiration_date is null or expiration_date >=?)", Time.new.to_date])    
  end
  
  # Deactivates all unanswered notifications for a particular variation and source id
  def self.deactivate_all(variation, source_id)
    update_all(variation,source_id,0,-1)
  end
  
  def self.activate_all(variation, source_id)
    update_all(variation,source_id,-1,0)
  end
  
  # Creates a notification (isolating this method so that we can add delayed job in the future)
  def self.create(recipient_id, variation, params, source_id)
    @notification = Notification.new
    @notification.recipient_id = recipient_id
    @notification.variation = variation
    @notification.params = params
    @notification.source_id = source_id
    @notification.save    
  end
  
  # -1 is deactivated
  # 0 is active and no response yet
  # 1 it has been responded to
  # 2 it has been archived
  def self.update_all(variation,source_id,initial_status,final_status)
    @notifications = self.find(:all, :conditions => ["source_id =? AND variation like '%#{variation}%' AND state =?", source_id, initial_status])
    @notifications.each do |@n|
      @n.state = final_status
      @n.save
    end    
  end
end
