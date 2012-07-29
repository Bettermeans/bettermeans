# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class JournalDetail < ActiveRecord::Base
  belongs_to :journal

  def before_save
    self.value = value[0..254] if value && value.is_a?(String)
    self.old_value = old_value[0..254] if old_value && old_value.is_a?(String)
  end
end

