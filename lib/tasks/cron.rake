task :cron => :environment do
# if Time.now.hour == 0
# 3.    puts "Updating feed..."
# 4.    NewsFeed.nightly_update
# 5.    puts "done."
# 6.  end
    puts "Running cron..."
    Rake::Task['backup'].invoke
    Rake::Task['autoaccept_commitrequests'].invoke
    Rake::Task['close_retros'].invoke
    Rake::Task['custom:refresh_active_members'].invoke
    Rake::Task['custom:lazy_majority'].invoke
    
    if Time.now.hour == 0
      last_distribution = CreditDistribution.first(:order => "updated_on DESC")
      last_distribution = last_distribution.updated_on unless last_distribution.nil?
      if (last_distribution.nil? || Time.now.advance(:days => Setting::TIME_BETWEEN_CREDIT_DISTRIBUTIONS * -1) > last_distribution)
        Rake::Task['distribute_retros'].invoke
      end
    end
    puts "done."
end