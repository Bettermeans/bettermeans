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

# Rejects/accepts lazy majority items after 3 days from their creation
  task :lazy_majority => :environment do
    Issue.all(:conditions => [ "status_id = ? AND updated_on < ?", IssueStatus.newstatus.id,DateTime.now - Setting::LAZY_MAJORITY_LENGTH ]).each do |issue|
      issue.update_status
    end

    Issue.all(:conditions => [ "status_id = ? AND updated_on < ?", IssueStatus.estimate.id,DateTime.now - Setting::LAZY_MAJORITY_LENGTH ]).each do |issue|
      issue.update_status
    end

    Issue.all(:conditions => [ "status_id = ? AND updated_on < ?", IssueStatus.done.id,DateTime.now - Setting::LAZY_MAJORITY_LENGTH ]).each do |issue|
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
  

  task :one_time_credit_to_point_adjust => :environment do
    IssueVote.all.each do |iv|
      next if iv.vote_type != IssueVote::ESTIMATE_VOTE_TYPE
      next if iv.issue.nil?
      next if Setting::POINT_FACTOR[iv.points].nil?
      next if iv.project.dpp.nil?
      puts (iv.points.to_s + " " + iv.project.dpp.to_s)
      iv.points = Setting::POINT_FACTOR[iv.points] * iv.project.dpp
      puts (iv.points.to_s)
      iv.save
    end
    
    Issue.all.each do |issue|
      issue.update_estimate_total true
      issue.update_estimate_total false
      issue.save
    end
    
    Retro.all.each do |r|
      puts (r.id.to_s)
      r.total_points = r.issues.collect(&:points).sum
      puts (r.total_points.to_s)
      r.save
    end
    
      
  end

end