class Notification < ActiveRecord::Base
  serialize :params

  belongs_to :recipient, :class_name => 'User', :foreign_key => 'recipient_id'  
  
  # named_scope :active, :conditions => ["state = 0"]
  # Returns all active, non responded, non-expired notifications
  named_scope :allactive, :conditions => ["state = 0 AND (expiration is null or expiration >=?)", Time.new.to_date]
  
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
    
  # # -1 is deactivated
  # # 0 is active and no response yet
  # # 1 it has been responded to
  # # 2 it has been archived
  # # 3 it has been recinded
  # def self.update_all(variation,source_id,initial_status,final_status, options = {})
  #   @notifications = self.find(:all, :conditions => ["source_id =? AND variation like '%#{variation}%' AND state =?", source_id, initial_status])
  #   @notifications.each do |@n|
  #     @n.state = final_status
  #     @n.save
  #   end    
  # end
  
  # Deactivates all unanswered notifications for a particular variation and source id
  def self.recind(variation, source_id, sender_id)
    @notifications = self.find(:all, :conditions => ["source_id =? AND variation =? AND state =0 AND params like'%:sender_id => ?%'", source_id, variation, sender_id])
    @notifications.each do |@n|
      @n.state = STATE_RECINDED
      @n.save
    end    
  end
  
  # Deactivates all unanswered notifications for a particular variation and source id
  def self.deactivate_all(variation, source_id)
    update_all(variation,source_id,0,STATE_DEACTIVATED)
  end
  
  def self.activate_all(variation, source_id)
    update_all(variation,source_id,-1,STATE_ACTIVE)
  end
end



# == Schema Information
#
# Table name: notifications
#
#  id           :integer         not null, primary key
#  recipient_id :integer
#  variation    :string(255)
#  params       :text
#  state        :integer         default(0)
#  source_id    :integer
#  expiration   :datetime
#  created_on   :datetime
#  updated_on   :datetime
#  sender_id    :integer
#

