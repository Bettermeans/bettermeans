require 'spec_helper'

describe Issue, '#update_last_item_stamp' do

  let(:issue) { Issue.new }

  it 'updates last item time stamp' do
    fake_project = stub()
    fake_project.should_receive(:send_later).with("update_last_item")
    issue.stub(:project).and_return(fake_project)
    issue.update_last_item_stamp
  end

end
