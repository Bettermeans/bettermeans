# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

class TimeEntryActivity < Enumeration
  has_many :time_entries, :foreign_key => 'activity_id'

  OptionName = :enumeration_activities
  # Backwards compatiblity.  Can be removed post-0.9
  OptName = 'ACTI'
  
  def option_name
    OptionName
  end

  def objects_count
    time_entries.count
  end

  def transfer_relations(to)
    time_entries.update_all("activity_id = #{to.id}")
  end
end
