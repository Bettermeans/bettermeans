class Todo < ActiveRecord::Base
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  belongs_to :issue
  
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
#  created_on   :datetime
#  updated_on   :datetime
#  owner_login  :string(255)
#

