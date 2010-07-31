class Plan < ActiveRecord::Base
  FREE_CODE = 0
end

# == Schema Information
#
# Table name: plans
#
#  id                     :integer         not null, primary key
#  name                   :string(255)
#  code                   :integer
#  description            :text
#  amount                 :float
#  storage_max            :integer
#  contributor_max        :integer
#  private_workstream_max :integer
#  public_workstream_max  :integer
#  created_on             :datetime
#  updated_on             :datetime
#

