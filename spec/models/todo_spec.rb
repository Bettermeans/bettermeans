require 'spec_helper'

describe Todo do
  describe "#update_issue_timestamp" do
    it "updates timestamp for todo.issue" do
      time = Time.now
      DateTime.stub(:now).and_return(time)
      todo = Todo.create!({:issue => Issue.new})
      todo.update_issue_timestamp
      todo.issue.updated_at.should == time
    end
  end
end
