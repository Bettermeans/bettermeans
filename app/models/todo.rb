class Todo < ActiveRecord::Base
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  belongs_to :issue

  after_save :update_issue_timestamp

  def update_issue_timestamp
    issue.updated_at = DateTime.now
    issue.save
  end

end



# == Schema Information
#
# Table name: todos
#
#  id           :integer         not null, primary key
#  subject      :string(255)
#  author_id    :integer
#  owner_id     :integer
#  issue_id     :integer
#  completed_on :datetime
#  created_at   :datetime
#  updated_at   :datetime
#  owner_login  :string(255)
#

