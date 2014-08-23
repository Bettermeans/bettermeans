require 'spec_helper'

describe Comment, '#mention' do

  let(:comment) { Comment.new }

  let(:params) { {:mention_text => "10 mentioned 11"} }
  let(:sender_id) { 10 }
  let(:recipient_id) { 11 }
  let(:notification) { Notification.create(comment_args) }

  it 'creates a new notification' do
    expect {
      comment.mention(sender_id, recipient_id, params)
    }.to change(Notification, :count).by(1)
  end

  it 'sends notification from correct sender' do
    comment.mention(sender_id, recipient_id, params)
    Notification.last.sender_id.should == sender_id
  end

  it 'sends notification to correct recipient' do
    comment.mention(sender_id, recipient_id, params)
    Notification.last.recipient_id.should == recipient_id
  end


end
