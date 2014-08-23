require 'spec_helper'

describe News, '#mention' do

  let(:author) { Factory.create(:user) }
  let(:project) { Factory.create(:project) }
  let(:news) { News.new(:author => author, :project => project) }
  let(:sender) { Factory.create(:user) }
  let(:recipient) { Factory.create(:user) }

  let(:notification) { Notification.create(:params => params, :sender => sender, :recipient => recipient) }

  it 'creates a new notification' do
    expect {
        news.mention(sender.id, recipient.id, 'blah')
      }.to change(Notification, :count).by(1)
  end

  it 'sends noitification from the correct sender' do
    news.mention(sender.id, recipient.id, 'blah')
    Notification.last.sender.should == sender
  end

  it 'sends notification to the correct recipient' do
    news.mention(sender.id, recipient.id, 'blah')
    Notification.last.recipient.should == recipient
  end

end
