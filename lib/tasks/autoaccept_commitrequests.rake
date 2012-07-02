# Auto accepts commitment requests that haven't been responded to

MINIMUM_INCREMENT = 2 #Minimum size of time increment (in days) that can go buy before the system auto-accepts a request
SECONDS_PER_DAY = 86400

def helpers
  ActionController::Base.helpers
end


desc "Auto accepts commitment requests that haven't been responded to"
task :autoaccept_commitrequests => :environment do
  admin = User.find(:first,:conditions => {:login => "admin"})

  CommitRequest.find(:all, :conditions => 'response = 0 AND responder_id is null AND days > -1').each do |cr|
    non_response_time = (Time.now - cr.created_at) / SECONDS_PER_DAY
    next if non_response_time < MINIMUM_INCREMENT
    if non_response_time > cr.days
      puts "Auto accepting: #{cr.id}  for issue #{cr.issue.subject}"

      cr.response = 2
      cr.responder_id = admin.id
      cr.save

      # Notification.create :recipient_id => cr.user_id,
      #                     :variation => 'message',
      #                     :params => :subject => helpers.t(:label_ownership_request_auto_accepted), :message => '#{helpers.t(:text_you_are_the_new_owner_of)} #{helpers.link_to cr.issue.tracker.name + ' ' + cr.issue.id.to_s + ': ' + cr.issue.subject, "/issues/" + cr.issue.id.to_s}', :sender_id => admin.id,
      #                     cr.issue_id

    end
  end
end
