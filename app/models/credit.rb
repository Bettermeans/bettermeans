class Credit < ActiveRecord::Base

  default_value_for :issued_on do
    Time.now
  end

  #Constants
  ROUNDING_LEVEL = 2 #How many digits to round down to when paying off

  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  belongs_to :project

  after_create :issue_shares

  def issue_day
    self.issued_on.strftime('%D')
  end

  def disable
    self.enabled = false
    return self.save
  end

  def enable
    self.enabled = true
    return self.save
  end

  #For every credit that is issue, a corresponding share is issued
  def issue_shares
    Share.create! :amount => amount, :owner => owner, :project => project, :issued_on => issued_on unless previously_issued #We don't create shares if we're creating credit for a past issue date (i.e. in case of an incomplete payoff)
  end

  def previously_issued
    (issued_on - created_at) > 2 #if created date is different than issued on date (by more than a few milliseconds) then this was a previously issued credit, that's being recreated as portion of shares already given out
  end

  def settled?
    return !self.settled.nil?
  end

  def pay_out(pay_amount)
    pay_amount = Credit.round(pay_amount)
    return false if pay_amount > amount #TODO raise an error here?
    original_amount = self.amount

    #Saving current record
    self.amount = pay_amount
    self.settled_on = Time.now
    self.save

    #We cashed out some credits, so we set some shares to expire
    Share.set_expiration(owner,project,pay_amount,Time.now + (Time.now - issued_on))

    #Wasn't fully paid out, we need to create a new entry with the remaining unissued credit
    if original_amount > pay_amount
      Credit.create! :amount => Credit.round(original_amount-pay_amount), :owner => owner, :project => project, :issued_on => issued_on
    end
  end

  def self.round(x)
      (x * 10**ROUNDING_LEVEL).floor.to_f / 10**ROUNDING_LEVEL #rounds down
  end

  #Pays out a certain amount of credit for a certain project (e.g. payout $6000 for the website project)
  #Owners on top of the stack are paid out first, and shares are updated accordingly
  def self.settle(project,amount)
    remaining_amount = amount

    Credit.find(:all,:conditions => {:project_id => project, :enabled => true, :settled_on => nil}, :order => 'issued_on ASC').group_by(&:issue_day).each do |day,credits|
      #Looping once for each day
      day_amount = credits.inject(0) {|sum, credit| sum = sum + credit.amount}
      if remaining_amount >= day_amount
        credits.each {|credit| credit.pay_out(credit.amount)} #payoff full amount of each credit
      else
        credits.each {|credit| credit.pay_out(credit.amount * remaining_amount / day_amount)} #payoff full amount of each credit
        break; #Stop looping through days
      end
      remaining_amount = remaining_amount - day_amount
      break if remaining_amount <= 0
    end

    remaining_amount <= 0 ? 0 : remaining_amount
  end

  #transfers a certain amount of credit for a certain user for a certain project to another user (e.g. shereef gives $6000 from the website project to adele)
  #newest credits are transfered first
  #returns total paid
  def self.transfer(sender,recipient,project,amount, note)
    remaining_amount = amount

    Credit.find(:all,:conditions => {:project_id => project.id, :settled_on => nil, :owner_id => sender.id}, :order => 'issued_on DESC').each do |credit|
      #Looping once for each day
      if remaining_amount >= credit.amount
        credit.owner_id = recipient.id
        credit.save
        remaining_amount = remaining_amount - credit.amount
      else
        credit.amount = Credit.round(credit.amount - remaining_amount)
        credit.save
        Credit.create! :amount => Credit.round(remaining_amount), :owner => recipient, :project => project
        remaining_amount = 0
        break; #Stop looping through days
      end

      break if remaining_amount <= 0
    end
    total_paid = Credit.round(amount - remaining_amount)

    CreditTransfer.create! :sender => sender, :recipient => recipient, :project => project, :amount => total_paid, :note => note if total_paid > 0

    return total_paid
  end


end





