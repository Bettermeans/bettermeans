# Redmine - project management software
# Copyright (C) 2006-2011  See readme for details and license#

class EnabledModule < ActiveRecord::Base
  belongs_to :project

  validates_presence_of :name

  after_create :module_enabled

  private

  # after_create callback used to do things when a module is enabled
  def module_enabled
    case name
    when 'wiki'
      # Create a wiki with a default start page
      if project && project.wiki.nil?
        Wiki.create(:project => project, :start_page => 'Wiki')
      end
    end
  end

end


# == Schema Information
#
# Table name: enabled_modules
#
#  id         :integer         not null, primary key
#  project_id :integer
#  name       :string(255)     not null
#

