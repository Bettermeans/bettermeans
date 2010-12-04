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
      puts "Refreshing #{project.id}: #{project.name}"
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

  task :deliver_personal_welcome => :environment do
    PersonalWelcome.deliver
  end
  
  #Used to trim a production database for development
  task :trim_database_for_dev => :environment do
    if ENV['reset_safe'] == 'true'
      puts "Trimming database"
      puts "Changing passwords"
      User.update_all(:hashed_password => "5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8")
      
      puts "Deleting projects"
      Project.all.each do |p|
        # puts "Root id #{p.root.id}"
        unless p.root && (p.root.id == 20 || p.root.id == 43)
          p.destroy
          puts "Deleted #{p.id}"
        end
      end
      
      puts "Deleting users"
      @p = Project.find(20) #bettermeans
      @p.name = "LOCAL BETTERMEANS" #changing title so there's not confusion when working with local db
      @p.save
      
      @q = Project.find(43) #green museum
      User.all.each do |u| 
        unless u.community_member_of?(@p) || u.community_member_of?(@q) || u.id == User.sysadmin.id 
          puts "Deleting user #{u.id}"
          u.destroy 
        end
      end
      
      puts "done."
    else
      puts "wont reset. we're not in development"
      puts "to allow reset use: export reset_safe=true"
    end
    
  end

end