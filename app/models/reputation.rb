class Reputation < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
end

# == Schema Information
#
# Table name: reputations
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  project_id      :integer
#  reputation_type :integer
#  value           :float
#  params          :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

