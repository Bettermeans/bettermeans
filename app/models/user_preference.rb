# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

class UserPreference < ActiveRecord::Base
  belongs_to :user
  serialize :others
  
  attr_protected :others
  
  def initialize(attributes = nil)
    super
    self.others ||= {}
  end
  
  def before_save
    self.others ||= {}
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
      h = read_attribute(:others).dup || {}
      h.update(attr_name => value)
      write_attribute(:others, h)
      value
    end
  end
  
  def comments_sorting; self[:comments_sorting] end
  def comments_sorting=(order); self[:comments_sorting]=order end
end


# == Schema Information
#
# Table name: user_preferences
#
#  id        :integer         not null, primary key
#  user_id   :integer         default(0), not null
#  others    :text
#  hide_mail :boolean         default(FALSE)
#  time_zone :string(255)
#

