class Plan < ActiveRecord::Base
  FREE_CODE = 0

  def free?
    return self.code == FREE_CODE
  end
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
#  created_at             :datetime
#  updated_at             :datetime
#

