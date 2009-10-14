# redMine - project management software
# Copyright (C) 2006-2007  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

module Redmine
  module DefaultData
    class DataAlreadyLoaded < Exception; end

    module Loader
      include Redmine::I18n
    
      class << self
        # Returns true if no data is already loaded in the database
        # otherwise false
        def no_data?
          !Role.find(:first, :conditions => {:builtin => 0}) &&
            !Tracker.find(:first) &&
            !IssueStatus.find(:first) &&
            !Enumeration.find(:first)
        end
        
        # Loads the default data
        # Raises a RecordNotSaved exception if something goes wrong
        def load(lang=nil)
          raise DataAlreadyLoaded.new("Some configuration data is already loaded.") unless no_data?
          set_language_if_valid(lang)
          
          Role.transaction do
            # Roles
            administrator = Role.create! :name => l(:default_role_administrator), :position => 1
            administrator.permissions = administrator.setable_permissions.collect {|p| p.name}
            administrator.permissions.delete(:edit_time_entries)
            
            administrator.save!
            
            citizen = Role.create! :name => l(:default_role_citizen), :position => 2
            citizen.permissions = citizen.setable_permissions.collect {|p| p.name}
            citizen.permissions.delete(:add_project)
            citizen.permissions.delete(:edit_project)
            citizen.permissions.delete(:select_projected_modules)
            citizen.permissions.delete(:manage_members)
            citizen.permissions.delete(:manage_versions)                                              
            citizen.permissions.delete(:edit_time_entries)
            citizen.save!

            contributor = Role.create! :name => l(:default_role_contributor), :position => 3
            contributor.permissions = contributor.setable_permissions.collect {|p| p.name}
            contributor.permissions.delete(:add_project)
            contributor.permissions.delete(:edit_project)
            contributor.permissions.delete(:select_projected_modules)
            contributor.permissions.delete(:manage_members)
            contributor.permissions.delete(:manage_versions)
            contributor.permissions.delete(:manage_boards)
            contributor.permissions.delete(:edit_messages)
            contributor.permissions.delete(:delete_messages)
            contributor.permissions.delete(:delete_own_messages)
            contributor.permissions.delete(:manage_documents)
            contributor.permissions.delete(:manage_files)
            contributor.permissions.delete(:manage_categories)
            contributor.permissions.delete(:manage_issue_relations)
            contributor.permissions.delete(:edit_issue_notes)
            contributor.permissions.delete(:move_issues)
            contributor.permissions.delete(:delete_issues)
            contributor.permissions.delete(:push_commitment)
            contributor.permissions.delete(:manage_public_queries)
            contributor.permissions.delete(:add_issue_watchers)
            contributor.permissions.delete(:manage_news)
            contributor.permissions.delete(:manage_repository)
            contributor.permissions.delete(:edit_time_entries)
            contributor.permissions.delete(:manage_wiki)
            contributor.permissions.delete(:rename_wiki_pages)
            contributor.permissions.delete(:delete_wiki_pages)
            contributor.permissions.delete(:delete_wiki_pages_attachments)
            contributor.permissions.delete(:protect_wiki_pages)
            contributor.save!            
                        
            Role.non_member.update_attribute :permissions, contributor.permissions
          
            Role.anonymous.update_attribute :permissions, [:view_gantt,
                                                           :view_calendar,
                                                           :view_time_entries,
                                                           :view_documents,
                                                           :view_wiki_pages,
                                                           :view_wiki_edits,
                                                           :view_files,
                                                           :view_changesets]
                                                             
            # Trackers
            Tracker.create!(:name => l(:default_tracker_task),     :is_in_chlog => true,  :is_in_roadmap => true, :position => 1)
            Tracker.create!(:name => l(:default_tracker_subtask), :is_in_chlog => true,  :is_in_roadmap => true,  :position => 2)
            
            # Issue statuses
            new       = IssueStatus.create!(:name => l(:default_issue_status_new), :is_closed => false, :is_default => true, :position => 1)
            assigned  = IssueStatus.create!(:name => l(:default_issue_status_assigned), :is_closed => false, :is_default => false, :position => 2)
            closed    = IssueStatus.create!(:name => l(:default_issue_status_closed), :is_closed => true, :is_default => false, :position => 3)
            blocked  = IssueStatus.create!(:name => l(:default_issue_status_blocked), :is_closed => false, :is_default => false, :position => 4)
            
            # Workflow
            Tracker.find(:all).each { |t|
              IssueStatus.find(:all).each { |os|
                IssueStatus.find(:all).each { |ns|
                  Workflow.create!(:tracker_id => t.id, :role_id => administrator.id, :old_status_id => os.id, :new_status_id => ns.id) unless os == ns
                }        
              }      
            }
            
            Tracker.find(:all).each { |t|
              IssueStatus.find(:all).each { |os|
                IssueStatus.find(:all).each { |ns|
                  Workflow.create!(:tracker_id => t.id, :role_id => citizen.id, :old_status_id => os.id, :new_status_id => ns.id) unless os == ns
                }        
              }      
            }
            
            Tracker.find(:all).each { |t|
              IssueStatus.find(:all).each { |os|
                IssueStatus.find(:all).each { |ns|
                  Workflow.create!(:tracker_id => t.id, :role_id => contributor.id, :old_status_id => os.id, :new_status_id => ns.id) unless os == ns
                }        
              }      
            }
          
            # Enumerations
            DocumentCategory.create!(:opt => "DCAT", :name => l(:default_doc_category_public), :position => 1)
            DocumentCategory.create!(:opt => "DCAT", :name => l(:default_doc_category_private), :position => 2)
          
            IssuePriority.create!(:opt => "IPRI", :name => l(:default_priority_low), :position => 1)
            IssuePriority.create!(:opt => "IPRI", :name => l(:default_priority_normal), :position => 2, :is_default => true)
            IssuePriority.create!(:opt => "IPRI", :name => l(:default_priority_high), :position => 3)
            IssuePriority.create!(:opt => "IPRI", :name => l(:default_priority_urgent), :position => 4)
          
            TimeEntryActivity.create!(:opt => "ACTI", :name => l(:default_activity_default), :position => 1)
            TimeEntryActivity.create!(:opt => "ACTI", :name => l(:default_activity_planning), :position => 2)
            TimeEntryActivity.create!(:opt => "ACTI", :name => l(:default_activity_execution), :position => 3)
          end
          true
        end
      end
    end
  end
end
