task :cron => :environment do
    puts "Running cron..."
    Rake::Task['backup'].invoke
    Rake::Task['close_retros'].invoke
    Rake::Task['custom:refresh_active_members'].invoke
    Rake::Task['custom:lazy_majority'].invoke
    Rake::Task['custom:close_motions'].invoke
    Rake::Task['custom:refresh_activity_timelines'].invoke

    if Time.now.hour == 18
      Rake::Task['custom:deliver_daily_digest'].invoke
    end

    if Time.now.hour == 0

      Rake::Task['heroku:daily_backup'].invoke
      Rake::Task['start_retros'].invoke
      Rake::Task['custom:calculate_reputation'].invoke
      Rake::Task['custom:calculate_project_storage'].invoke
      Rake::Task['custom:detect_users_over_limit'].invoke
      Rake::Task['custom:detect_trial_expiration'].invoke
      Rake::Task['custom:refresh_project_issue_counts'].invoke

    end
    puts "done."
end
