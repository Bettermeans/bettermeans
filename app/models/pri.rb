class Pri < ActiveRecord::Base
  belongs_to :user
  belongs_to :issue
  
  before_create :remove_similar_pris
  after_create :update_issue_pri
  after_update :update_issue_pri
  after_destroy :update_issue_pri

  #user is only allowed one pri per issue
  def remove_similar_pris
    Pri.delete_all(:issue_id => issue_id, :user_id => user_id)
  end  
  
  #updates total priorities for that issue
  def update_issue_pri
    issue.update_pri
  end
end

# == Schema Information
#
# Table name: pris
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  issue_id   :integer
#  created_on :datetime
#  updated_on :datetime
#

