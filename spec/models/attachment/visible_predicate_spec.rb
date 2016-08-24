require 'spec_helper'

describe Attachment, '#visible?' do

  it 'returns true when user can view attachments for container' do
    issue = Issue.new
    fake_user = double
    attachment = Attachment.new(:container => issue)
    issue.should_receive(:attachments_visible?).with(fake_user).and_return(true)
    attachment.visible?(fake_user).should be true
  end

  it 'returns false when user cannot view attachments for container' do
    issue = Issue.new
    fake_user = double
    attachment = Attachment.new(:container => issue)
    issue.stub(:attachments_visible?).with(fake_user).and_return(false)
    attachment.visible?(fake_user).should be false
  end

  it 'defaults to the current user' do
    issue = Issue.new
    fake_user = double
    attachment = Attachment.new(:container => issue)
    issue.should_receive(:attachments_visible?).with(fake_user).and_return(true)
    User.current = fake_user
    attachment.visible?.should be true
  end

end
