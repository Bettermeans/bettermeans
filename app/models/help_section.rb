class HelpSection < ActiveRecord::Base
  belongs_to :user
end

# == Schema Information
#
# Table name: help_sections
#
#  id         :integer         not null, primary key
#  user_id    :integer         default(0), not null
#  name       :string(255)
#  show       :boolean         default(TRUE)
#  created_on :datetime
#  updated_on :datetime
#

