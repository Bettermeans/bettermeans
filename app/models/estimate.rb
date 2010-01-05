class Estimate < ActiveRecord::Base
  belongs_to :user
  belongs_to :issue
  before_create :remove_similar_estimates
  after_create :update_issue_totals
  after_update :update_issue_totals
  after_destroy :update_issue_totals
  
  #Todo: Delay job this
  def update_issue_totals
    issue.update_point_average
  end
  
  def remove_similar_estimates
    Estimate.delete_all(:issue_id => issue_id, :user_id => user_id)
  end
end

# == Schema Information
#
# Table name: estimates
#
#  id         :integer         not null, primary key
#  points     :integer         not null
#  user_id    :integer         not null
#  issue_id   :integer         not null
#  created_on :datetime
#  updated_on :datetime
#

