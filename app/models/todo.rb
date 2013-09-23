class Todo < ActiveRecord::Base
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  belongs_to :issue

  after_save :update_issue_timestamp

  def update_issue_timestamp # spec_me cover_me heckle_me
    issue.updated_at = DateTime.now
    issue.save
  end

end


