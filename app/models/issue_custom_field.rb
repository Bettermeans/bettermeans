# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

class IssueCustomField < CustomField
  has_and_belongs_to_many :projects, :join_table => "#{table_name_prefix}custom_fields_projects#{table_name_suffix}", :foreign_key => "custom_field_id"
  has_and_belongs_to_many :trackers, :join_table => "#{table_name_prefix}custom_fields_trackers#{table_name_suffix}", :foreign_key => "custom_field_id"
  has_many :issues, :through => :issue_custom_values
    
  def type_name
    :label_issue_plural
  end
end



# == Schema Information
#
# Table name: custom_fields
#
#  id              :integer         not null, primary key
#  type            :string(30)      default(""), not null
#  name            :string(30)      default(""), not null
#  field_format    :string(30)      default(""), not null
#  possible_values :text
#  regexp          :string(255)     default("")
#  min_length      :integer         default(0), not null
#  max_length      :integer         default(0), not null
#  is_required     :boolean         default(FALSE), not null
#  is_for_all      :boolean         default(FALSE), not null
#  is_filter       :boolean         default(FALSE), not null
#  position        :integer         default(1)
#  searchable      :boolean         default(FALSE)
#  default_value   :text
#  editable        :boolean         default(TRUE)
#

