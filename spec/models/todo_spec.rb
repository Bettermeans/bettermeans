require 'spec_helper'

describe Todo do
  describe "#update_issue_timestamp" do
    it "updates timestamp for todo.issue" do
      time = 5.days.ago
      todo = Todo.create!({:issue => Issue.new})
      todo.issue.updated_at = time
      todo.issue.updated_at.should == time
      todo.update_issue_timestamp
      todo.issue.updated_at.should_not == time
    end
  end
end
