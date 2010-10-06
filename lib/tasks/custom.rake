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
    Issue.all(:conditions => [ "status_id = ? AND updated_at < ?", IssueStatus.newstatus.id,DateTime.now - Setting::LAZY_MAJORITY_NO_ACTIVITY_LENGTH ]).each do |issue|
      issue.update_status
    end

    Issue.all(:conditions => [ "status_id = ? AND updated_at < ?", IssueStatus.estimate.id,DateTime.now - Setting::LAZY_MAJORITY_NO_ACTIVITY_LENGTH ]).each do |issue|
      issue.update_status
    end

    Issue.all(:conditions => [ "status_id = ? AND updated_at < ?", IssueStatus.done.id,DateTime.now - Setting::LAZY_MAJORITY_NO_ACTIVITY_LENGTH ]).each do |issue|
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
  
  #one time fix for credits tables, and makes sure all projects have credit module enabled
  task :run_once_fix_credit_distros => :environment do
    CreditDistribution.all.each do |cd|
      credit = Credit.find(:first, :conditions => {:owner_id => cd.user_id, :amount => cd.amount})
      credit.project_id = cd.project_id
      credit.save
    end
  
    Project.all.each do |p|
      p.enabled_modules << EnabledModule.create(:name => "credits")
    end
  end
  
  #maps all users to recurly users
  task :create_recurly_users => :environment do
    User.all.each do |user|
      User.create_recurly_account(user.id)
    end
  end

  task :calculate_project_storage => :environment do
    Project.all.each do |p| p.calculate_storage end
  end
  
  task :add_daily_digest_option_to_users => :environment do
    User.all.each do |user|
      user.pref.others.merge!({:daily_digest => true})
      user.pref.save
    end
  end

  task :deliver_daily_digest => :environment do
    DailyDigest.deliver
  end
  
  

end