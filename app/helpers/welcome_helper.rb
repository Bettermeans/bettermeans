# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

module WelcomeHelper
  def my_issues_tabs
    tabs = [
            {:name => 'assigned', 
             :partial => 'issues/list_very_simple', 
             :label => :label_assigned, 
             :label_ending => " (#{@assigned_issues.length})",
             :locals => {:issues => @assigned_issues}
            },
            # {:name => 'joined', 
            #  :partial => 'issues/list_very_simple', 
            #  :label => :label_joined, 
            #  :label_ending => " (#{@joined_issues.length})",
            #  :locals => {:issues => @joined_issues}
            # },
            {:name => 'watched', 
             :partial => 'issues/list_very_simple', 
             :label => :label_watched, 
             :label_ending => " (#{@watched_issues.length})",
             :locals => {:issues => @watched_issues}
            }
          ]
  end
end
