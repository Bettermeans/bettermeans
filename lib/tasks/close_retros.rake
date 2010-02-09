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
      puts "Auto closing retro: #{retro.id}"
      retro.close
    elsif retro.all_in?
      puts "Closing retro: #{retro.id} becuase all is in"
      retro.close
    end
      
    # Notification.create cr.user_id,
    #           'message',
    #           ":subject => '#{helpers.t(:label_ownership_request_auto_accepted)}', :message => '#{helpers.t(:text_you_are_the_new_owner_of)} #{helpers.link_to cr.issue.tracker.name + ' ' + cr.issue.id.to_s + ': ' + cr.issue.subject, "/issues/" + cr.issue.id.to_s}', :sender_id => #{admin.id}",
    #           cr.issue_id

  
  end
end