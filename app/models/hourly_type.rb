class HourlyType < ActiveRecord::Base
  belongs_to :project
  has_many :issues

  validates_presence_of :name, :project, :hourly_rate_per_person, :hourly_cap
  validates_length_of :name,        :maximum => 255
  validates_numericality_of :hourly_rate_per_person, :hourly_cap

  def validate
    errors.add(:hourly_rate_per_person, "should be at least 1") if hourly_rate_per_person.nil? || hourly_rate_per_person < 1
    errors.add(:hourly_cap, "should be at least 1") if hourly_cap.nil? || hourly_cap < 1
  end

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

