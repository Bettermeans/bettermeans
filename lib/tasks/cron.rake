task :cron => :environment do
# if Time.now.hour == 0
# 3.    puts "Updating feed..."
# 4.    NewsFeed.nightly_update
# 5.    puts "done."
# 6.  end
    puts "Running cron..."
    Rake::Task['backup'].invoke
    puts "done."
end