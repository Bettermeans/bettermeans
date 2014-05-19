class ProjectsTracker < ActiveRecord::Base

  belongs_to :project
  belongs_to :tracker

  validates_presence_of :project, :tracker

end
