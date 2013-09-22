class HourlyType < ActiveRecord::Base
  belongs_to :project
  has_many :issues

  validates_presence_of :name, :project, :hourly_rate_per_person, :hourly_cap
  validates_length_of :name,        :maximum => 255
  validates_numericality_of :hourly_rate_per_person, :hourly_cap

  def validate # spec_me cover_me heckle_me
    errors.add(:hourly_rate_per_person, "should be at least 1") if hourly_rate_per_person.nil? || hourly_rate_per_person < 1
    errors.add(:hourly_cap, "should be at least 1") if hourly_cap.nil? || hourly_cap < 1
  end

  def name_with_rates # spec_me cover_me heckle_me
    "#{name} -- rate per person: #{hourly_rate_per_person}, cap: #{hourly_cap}"
  end
end


