# Used once

desc "removes item of type : problem and changes them to type : taks"
task :remove_problem_type => :environment do

  problem = Tracker.first(:conditions => {:name => "Problem"})
  task = Tracker.first(:conditions => {:name => "Task"})

  Issue.find(:all, :conditions => {:tracker_id => problem.id }).each do |issue|
    issue.tracker = task
    issue.save
    puts "#{issue.subject}"
  end
end
