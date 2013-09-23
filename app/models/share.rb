class Share < ActiveRecord::Base

  default_value_for :issued_on do
    Time.now
  end

  #Constants
  VARIATION_FOUNDER = 1 #issue when enterprise starts. don't expire
  VARIATION_CREDIT = 2 #issued when credit is issued, expire

  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  belongs_to :project
  named_scope :for_project, lambda { |*project_id|
    {:conditions => {:project_id => project_id}}
  }




  def self.set_expiration(owner,project,amount,expiration_date) # spec_me cover_me heckle_me
    remaining_amount = amount
    Share.find(:all,:conditions => {:expires => nil, :project_id => project.id, :owner_id => owner.id, :variation => VARIATION_CREDIT}, :order => 'issued_on ASC').each do |share|
      if share.amount <= remaining_amount
        share.expires = expiration_date
        remaining_amount = remaining_amount - share.amount
        share.save
      else
        #More shares in this lot than we are expiring
        unexpired_amount = Credit.round(share.amount - remaining_amount)
        #modify the amount for this lot to the expiring amount after rounding
        share.amount = share.amount - unexpired_amount
        share.expires = expiration_date
        share.save
        #create a new lot with the remaining unexpired shares
        Share.create! :amount => unexpired_amount, :owner => share.owner, :project => share.project, :issued_on => share.issued_on
        break;
      end
    end
  end

end

