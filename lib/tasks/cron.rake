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
    puts "done."
end