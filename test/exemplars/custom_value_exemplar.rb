class CustomValue < ActiveRecord::Base
end

# == Schema Information
#
# Table name: custom_values
#
#  id              :integer         not null, primary key
#  customized_type :string(30)      default(""), not null
#  customized_id   :integer         default(0), not null
#  custom_field_id :integer         default(0), not null
#  value           :text
#

