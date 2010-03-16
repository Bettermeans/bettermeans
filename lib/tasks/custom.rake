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
      
  end

end