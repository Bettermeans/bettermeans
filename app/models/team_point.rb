class TeamPoint < ActiveRecord::Base
  fields do
    project_id :integer 
    author_id :integer 
    recipient_id :integer
    timestamps
  end
  
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  belongs_to :recipient, :class_name => 'User', :foreign_key => 'recipient_id'
  belongs_to :project
  
  def after_create
    recalculate_core_membership
  end

  def after_update
    recalculate_core_membership
  end
  
  def after_destroy
    recalculate_core_membership
  end
  
  #Re-assesses wether or not recipient is a core member of the team depending on total points
  def recalculate_core_membership
  end

  
end
