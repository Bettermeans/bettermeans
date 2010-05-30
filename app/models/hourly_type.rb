class HourlyType < ActiveRecord::Base
  belongs_to :project
  has_many :issues
  
  validates_presence_of :name, :project, :hourly_rate_per_person, :hourly_cap
  validates_length_of :name,        :maximum => 255  
  
  def name_with_rates
    "#{name} -- rate per person: #{hourly_rate_per_person}, cap: #{hourly_cap}"
  end
end



# == Schema Information
#
# Table name: hourly_types
#
#  id                     :integer         not null, primary key
#  project_id             :integer
#  name                   :string(255)
#  hourly_rate_per_person :decimal(8, 2)
#  hourly_cap             :decimal(8, 2)
#  created_at             :datetime
#  updated_at             :datetime
#

