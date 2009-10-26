# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

module SettingsHelper
  def administration_settings_tabs
    tabs = [{:name => 'general', :partial => 'settings/general', :label => :label_general},
            {:name => 'display', :partial => 'settings/display', :label => :label_display},
            {:name => 'authentication', :partial => 'settings/authentication', :label => :label_authentication},
            {:name => 'projects', :partial => 'settings/projects', :label => :label_project_plural},
            {:name => 'issues', :partial => 'settings/issues', :label => :label_issue_tracking},
            {:name => 'notifications', :partial => 'settings/notifications', :label => :field_mail_notification},
            {:name => 'mail_handler', :partial => 'settings/mail_handler', :label => :label_incoming_emails},
            {:name => 'repositories', :partial => 'settings/repositories', :label => :label_repository_plural}
            ]
  end
end
