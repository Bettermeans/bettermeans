# BetterMeans - Work 2.0
# Copyright (C) 2008  Shereef Bishay
#

desc <<-END_DESC
Send reminders about issues due in the next days.

Available options:
  * days     => number of days to remind about (defaults to 7)
  * tracker  => id of tracker (defaults to all trackers)
  * project  => id or identifier of project (defaults to all projects)

Example:
  rake redmine:send_reminders days=7 RAILS_ENV="production"
END_DESC

namespace :redmine do
  task :send_reminders => :environment do
    options = {}
    options[:days] = ENV['days'].to_i if ENV['days']
    options[:project] = ENV['project'] if ENV['project']
    options[:tracker] = ENV['tracker'].to_i if ENV['tracker']

    Mailer.reminders(options)
  end
end
