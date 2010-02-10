# Closes retrospectives that are open

def helpers
  ActionController::Base.helpers
end


desc "Closes retrospectives that are open"
task :close_retros => :environment do
  admin = User.find(:first,:conditions => {:login => "admin"})
  puts "Closing retros..."
  Retro.find(:all, :conditions => {:status_id => Retro::STATUS_INPROGRESS}).each do |retro|
    if (Time.now > retro.to_date)
      retro.close
    elsif retro.all_in?
      retro.close
    end
  end
end