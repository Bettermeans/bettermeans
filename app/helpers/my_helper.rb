# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

module MyHelper
  def describe(amount)
    amount == -1 ? 'unlimited' : amount
  end
  
  def upgrade_options(user)
    if user.plan.code == Plan::FREE_CODE
      link_to "Upgrade", {:controller => :my, :action => :upgrade}, :class => "gt-btn-blue-large"
    else
      link_to "Upgrade / Downgrade", {:controller => :my, :action => :upgrade}, :class => "gt-btn-blue-large"
    end
  end
end
