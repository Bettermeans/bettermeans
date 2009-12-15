class TimeEntry < ActiveRecord::Base
  generator_for(:spent_on) { Date.today }
  generator_for(:hours) { (rand * 10).round(2) } # 0.01 to 9.99

end

# == Schema Information
#
# Table name: time_entries
#
#  id          :integer         not null, primary key
#  project_id  :integer         not null
#  user_id     :integer         not null
#  issue_id    :integer
#  hours       :float           not null
#  comments    :string(255)
#  activity_id :integer         not null
#  spent_on    :date            not null
#  tyear       :integer         not null
#  tmonth      :integer         not null
#  tweek       :integer         not null
#  created_on  :datetime        not null
#  updated_on  :datetime        not null
#

