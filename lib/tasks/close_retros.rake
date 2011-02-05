# Closes retrospectives that are open

def helpers
  ActionController::Base.helpers
end


desc "Closes retrospectives that are open"
task :close_retros => :environment do
  puts "Closing retros..."
  Retro.find(:all, :conditions => {:status_id => Retro::STATUS_INPROGRESS}).each do |retro|
    if ((Time.now.advance(:days => Setting::DEFAULT_RETROSPECTIVE_LENGTH * -1)  > retro.created_at) || retro.all_in?)
      retro.close
      retro.distribute_credits
    end
  end
end


# desc "Distribute retrospectives that are closed"
# task :distribute_retros => :environment do
#   puts "Distributing retros..."
#   Retro.find(:all, :conditions => {:status_id => Retro::STATUS_COMPLETE}).each do |retro|
#     puts "Distributing #{retro.id}"
#     retro.distribute_credits
#   end
# end

desc "Start retrospectives that are ready to be started"
task :start_retros => :environment do
  Project.all.each do |project|
    project.start_retro_if_ready
  end
end

