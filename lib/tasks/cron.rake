task :cron => :environment do
# if Time.now.hour == 0
# 3.    puts "Updating feed..."
# 4.    NewsFeed.nightly_update
# 5.    puts "done."
# 6.  end
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

    if Time.now.hour == 17 || Time.now.hour == 9
      Rake::Task['custom:deliver_personal_welcome'].invoke
    end

    # # Credit distribution
    # last_distribution = CreditDistribution.first(:order => "updated_at DESC")
    # last_distribution = last_distribution.updated_at unless last_distribution.nil?
    # if (last_distribution.nil? || Time.now.advance(:days => Setting::TIME_BETWEEN_CREDIT_DISTRIBUTIONS * -1) > last_distribution)
    #   Rake::Task['distribute_retros'].invoke
    # end
    
    
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