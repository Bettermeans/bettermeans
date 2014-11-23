# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

module Redmine
  module DefaultData
    class DataAlreadyLoaded < Exception; end

    module Loader
      include Redmine::I18n

      class << self
        # Returns true if no data is already loaded in the database
        # otherwise false
        def no_data? # spec_me cover_me heckle_me
          !Role.find(:first, :conditions => {:builtin => 0}) &&
            !Tracker.find(:first) &&
            !IssueStatus.find(:first) &&
            !Enumeration.find(:first)
        end

        # Loads the default data
        # Raises a RecordNotSaved exception if something goes wrong
        def load(lang=nil) # spec_me cover_me heckle_me
          raise DataAlreadyLoaded.new("Some configuration data is already loaded.") unless no_data?
          set_language_if_valid(lang)

          Role.transaction do
            # Roles
            administrator = Role.create! :name => l(:default_role_administrator), :position => 1, :builtin => Role::BUILTIN_ADMINISTRATOR
            administrator.permissions = administrator.setable_permissions.collect {|p| p.name}
            administrator.permissions.delete(:edit_time_entries)
            administrator.permissions.delete(:manage_members)

            administrator.save!

            citizen = Role.create! :name => l(:default_role_citizen), :position => 2, :builtin => Role::BUILTIN_CORE_MEMBER
            citizen.permissions = citizen.setable_permissions.collect {|p| p.name}
            citizen.permissions.delete(:add_project)
            citizen.permissions.delete(:edit_project)
            citizen.permissions.delete(:select_projected_modules)
            citizen.permissions.delete(:manage_members)
            citizen.permissions.delete(:manage_versions)
            citizen.permissions.delete(:edit_time_entries)
            citizen.save!

            contributor = Role.create! :name => l(:default_role_contributor), :position => 3, :builtin => Role::BUILTIN_CONTRIBUTOR
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
            contributor.permissions.delete(:edit_time_entries)
            contributor.permissions.delete(:manage_wiki)
            contributor.permissions.delete(:rename_wiki_pages)
            contributor.permissions.delete(:delete_wiki_pages)
            contributor.permissions.delete(:delete_wiki_pages_attachments)
            contributor.permissions.delete(:protect_wiki_pages)
            contributor.save!

            #TODO: Check that built in role aren't in there before creating them
            @nonmember = Role.new(:name => 'Non member', :position => 0)
            @nonmember.builtin = Role::BUILTIN_NON_MEMBER
            @nonmember.save

            @anonymous = Role.new(:name => 'Anonymous', :position => 0)
            @anonymous.builtin = Role::BUILTIN_ANONYMOUS
            @anonymous.save

            Role.non_member.update_attribute :permissions, contributor.permissions

            Role.anonymous.update_attribute :permissions, [:view_issues,
                                                           :view_gantt,
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
            new       = IssueStatus.create!(:name => 'New', :is_closed => false, :is_default => true, :position => 1)
            assigned  = IssueStatus.create!(:name => 'Committed', :is_closed => false, :is_default => false, :position => 2)
            closed    = IssueStatus.create!(:name => 'Closed', :is_closed => true, :is_default => false, :position => 3)
            blocked  = IssueStatus.create!(:name => 'Blocked', :is_closed => false, :is_default => false, :position => 4)

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
          end
          true
        end
      end
    end
  end
end
