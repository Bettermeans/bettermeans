class HourlyType < ActiveRecord::Base
  belongs_to :project
  
  validates_presence_of :name, :project
  
  validates_length_of :name,        :maximum => 255
  validates_length_of :description, :maximum => 1000, :allow_nil => true
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

