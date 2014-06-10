require 'spec_helper'

describe Issue, '#after_create' do

  let(:issue) { Issue.new }

  it 'return project details and increase Job count by 1' do
    fake_project = stub()
    fake_project.should_receive(:send_later).with(:refresh_issue_count)
    issue.stub(:project).and_return(fake_project)
    issue.after_create
  end

end
