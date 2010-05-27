class HourlyType < ActiveRecord::Base
  belongs_to :project
end

# == Schema Information
#
# Table name: hourly_types
#
#  id          :integer         not null, primary key
#  name        :string(255)     not null
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

