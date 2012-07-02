# Updates item status to Done or Canceled depending on what their % complete is
# Used once for migrating to new more defined item statuses

desc "update item statuses to Done or Canceled depending on what their % complete is"
task :update_item_statuses => :environment do

  done = IssueStatus.first(:conditions => {:name => "Done"})
  canceled = IssueStatus.first(:conditions => {:name => "Canceled"})
  closed = IssueStatus.first(:conditions => {:name => "Closed"})
  Issue.find(:all, :conditions => {:status_id => closed.id }).each do |issue|
    issue.done_ratio < 100 ? issue.status = canceled : issue.status = done
    issue.save
  end
end
