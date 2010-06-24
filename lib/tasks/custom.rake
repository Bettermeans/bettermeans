namespace :custom do
  task :load_test_data => :environment do
      # RAILS_ENV='test'
      # Rake::Task["db:test:prepare"]
      system 'rake db:test:prepare'
      system 'rake environment RAILS_ENV=test redmine:load_default_data'
      # system 'rake environment RAILS_ENV=test db:migrate'
      # Rake::Task["redmine:load_default_data"].invoke
      #Rake::Task["cucumber"].invoke
      # Redmine::DefaultData::Loader.load('en')
      
  end

  task :refresh_active_members => :environment do
    Project.all.each do |project|
      project.refresh_active_members
    end
      
  end

# Rejects/accepts lazy majority items that haven't had any activity for a certain number of days (LAZY_MAJORITY_NO_ACTIVITY_LENGTH)
  task :lazy_majority => :environment do
    Issue.all(:conditions => [ "status_id = ? AND updated_on < ?", IssueStatus.newstatus.id,DateTime.now - Setting::LAZY_MAJORITY_NO_ACTIVITY_LENGTH ]).each do |issue|
      issue.update_status
    end

    Issue.all(:conditions => [ "status_id = ? AND updated_on < ?", IssueStatus.estimate.id,DateTime.now - Setting::LAZY_MAJORITY_NO_ACTIVITY_LENGTH ]).each do |issue|
      issue.update_status
    end

    Issue.all(:conditions => [ "status_id = ? AND updated_on < ?", IssueStatus.done.id,DateTime.now - Setting::LAZY_MAJORITY_NO_ACTIVITY_LENGTH ]).each do |issue|
      issue.update_status
    end
  end

# loops through active motions and makes a decision on them
  task :close_motions => :environment do
    Motion.allactive.each do |motion|
      motion.close
    end
  end

  task :calculate_reputation => :environment do
    Reputation.calculate_all
  end

  task :refresh_activity_timelines => :environment do
    Project.all_roots.each {|p| p.refresh_activity_line} 
  end
  

end