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
  
  #sanity checks all project issue counts
  task :refresh_project_issue_counts => :environment do
    Project.all.each do |p|
      p.refresh_issue_count
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
  
  #temporary task to re-assign admins that have been lost
  task :run_once_fix_owners => :environment do
    Project.all.each do |p|
      next unless p.administrators == [] && p.root?
      p.owner.add_to_project(p, Role.administrator)
      p.owner.add_to_project(p, Role.core_member)
      
      p.all_members.each do |ms|
        if ms.created_at > Time.now.advance(:minutes => -2)
          ms.created_at = p.created_at
          ms.save
        end
        
        ms.member_roles.each do |mr|
          if mr.created_at > Time.now.advance(:minutes => -2)
            mr.created_at = p.created_at
            mr.save
          end
        end
      end
        
      puts "fixed #{p.id} #{p.name}"
    end
  end
  
  #one time fix to add members again, after they've been lost
  task :run_once_rerun_membership_motions => :environment do
    Motion.find(:all, :conditions => ["created_at > ?", Time.parse('10/1/2010')], :order => "created_at ASC").each do |m|
      m.execute_action
    end
  end
  
  
  #fixing the dropped member roles by re-adding all accepted invitations
  task :run_once_fix_invitations => :environment do
    Invitation.all.each do |i|
      next if i.status == 0
      unless i.user.enterprise_member_of?(i.project)
        puts "Adding #{i.user.name} #{i.user.id} to project #{i.project.name} #{i.project.id} as #{i.role.name}" 
        i.user.add_to_project(i.project,i.role)
      end
    end
  end
  

  #Used to trim a production database for development
  task :trim_db => :environment do
    if ENV['reset_safe'] == 'true'
      puts "Trimming database"

      @p = Project.find(20) #bettermeans
      @p.name = "LOCAL BETTERMEANS" #changing title so there's not confusion when working with local db
      @p.save
      
      # puts "Deleting old notifications"
      # Notification.delete_all
      # 
      # 
      # puts "Deleting users"
      # 
      # @q = Project.find(43) #green museum
      # 
      # User.all.each do |u| 
      #   unless u.community_member_of?(@p) || u.community_member_of?(@q) || u.id == User.sysadmin.id 
      #     puts "Deleting user #{u.id}"
      #     u.destroy 
      #   end
      # end
      
      puts "Deleting private projects"
      Project.all.each do |p|
        next if p.is_public?
        puts "Deleting project #{p.id} #{p.name}"
        p.destroy
        puts "done."
      end
      
      puts "Changing passwords to 'password' "
      User.update_all(:hashed_password => "5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8")

      puts "Changing emails"
      User.all.each do |user|
        user.mail = "#{(0...20).map{65.+(rand(25)).chr}.join}@bogus.com"
        user.save
      end
      
      puts "done."
    else
      puts "wont reset. we're not in development"
      puts "to allow reset use: export reset_safe=true"
    end
    
  end
  
  #detecting users that are overusing their plans and need to upgrade
  task :detect_users_over_limit => :environment do
    User.active.each do |u|
      u.update_usage_over
    end
  end

  #detecting users whose trials have expired and need to pay
  task :detect_trial_expiration => :environment do
    User.active.each do |u|
      u.update_trial_expiration
    end
  end
  
  #moving from features to tags
  task :run_once_features_to_task => :environment do
    Issue.all.each do |i|
      begin
      tag = i.tracker.name.downcase
      unless tag == "feature"
        puts("Upgrading issue #{i.id}  #{tag}")
        i.update_attribute(:tag_list,i.tag_list.add(tag))
      end
      i.update_attribute(:tags_copy, i.tags.join(","))
      rescue
        puts("FAILED TO UPGRADE issue #{i.id}")
      end
    end  
  end
  
  #moving from features to tags
  task :run_once_fix_retros => :environment do
    Retro.all.each do |r|
      if r.status_id == 3 && r.total_points > 0
        dist = CreditDistribution.find_by_retro_id(r.id)
        unless dist
          puts("retro #{r.id} for #{r.project.name}")
          r.update_attribute(:status_id, 2)
          r.distribute_credits
        end
      end
    end  
  end
  
end