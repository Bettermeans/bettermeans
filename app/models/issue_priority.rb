# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

class IssuePriority < Enumeration
  has_many :issues, :foreign_key => 'priority_id'

  OptionName = :enumeration_issue_priorities
  # Backwards compatiblity.  Can be removed post-0.9
  OptName = 'IPRI'

  def option_name
    OptionName
  end

  def objects_count
    issues.count
  end

  def transfer_relations(to)
    issues.update_all("priority_id = #{to.id}")
  end
end


# == Schema Information
#
# Table name: enumerations
#
#  id         :integer         not null, primary key
#  opt        :string(4)       default(""), not null
#  name       :string(30)      default(""), not null
#  position   :integer         default(1)
#  is_default :boolean         default(FALSE), not null
#  type       :string(255)
#  active     :boolean         default(TRUE), not null
#  project_id :integer
#  parent_id  :integer
#

