class CreditDistribution < ActiveRecord::Base
  after_create :add_credits
  belongs_to :project
  belongs_to :retro
  belongs_to :user
  
  GIFT = -1 #value in retro_id when distribution is a result of a gift, not a retrospective
  HOURLY = -2 # value in retro_id when distribution is a result of an hourly, not a retrospective
  
  def add_credits
    Credit.create :owner_id => self.user_id, :project_id => self.project.root.id, :amount => self.amount
    
    #Add as contributor
    self.user.add_as_contributor_if_new(self.project)
    
    
    admin = User.find(:first,:conditions => {:login => "admin"})
    Notification.create :recipient_id => self.user_id,
                        :variation => 'credits_distributed',
                        :params => {:project_name => project.name, :credit_distribution => self.attributes, :enterprise_id => self.project.root.id}, 
                        :sender_id => admin.id,
                        :source_id => self.id     
  end
end

# == Schema Information
#
# Table name: credit_distributions
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  project_id :integer
#  retro_id   :integer
#  amount     :float
#  created_on :datetime
#  updated_on :datetime
#

