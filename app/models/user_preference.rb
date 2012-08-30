# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class UserPreference < ActiveRecord::Base
  belongs_to :user
  serialize :others

  attr_protected :others

  DEFAULTS = {:no_self_notified=>true, :daily_digest=>true, :no_emails=>false,  :comments_sorting=>"asc", :active_only_jumps=>false}

  # BUGBUG: this initialize won't work consistently
  # when extending from ActiveRecord initialize doesn't always get called
  # http://blog.dalethatcher.com/2008/03/rails-dont-override-initialize-on.html
  # better to make this an after_initialize
  def initialize(attributes = nil)
    super
    self.others ||= DEFAULTS
  end

  def before_save
    self.others ||= DEFAULTS
  end

  def [](attr_name)
    if attribute_present? attr_name
      super
    else
      others ? others[attr_name] : nil
    end
  end

  def []=(attr_name, value)
    if attribute_present? attr_name
      super
    else
      h = read_attribute(:others).dup || DEFAULTS
      h.update(attr_name => value)
      write_attribute(:others, h)
      value
    end
  end

  def comments_sorting; self[:comments_sorting] end
  def comments_sorting=(order); self[:comments_sorting]=order end
end


