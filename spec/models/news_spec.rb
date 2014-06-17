require 'spec_helper'

describe News do

  let(:author) { Factory.create(:user) }
  let(:project) { Factory.create(:project) }
  let(:news) { News.new(:author => author, :project => project) }

  describe 'associations' do
    it { should have_many(:comments).dependent(:delete_all) }
  end

  describe "#valid?" do
    it { should belong_to(:project) }
    it { should belong_to(:author) }

    it { should ensure_length_of(:title).is_at_most(60) }
    it { should ensure_length_of(:summary).is_at_most(255) }
  end

  describe '#visible?' do
    context 'when a current user exists and has view permission' do
      it 'returns true' do
        author.stub(:allowed_to?).and_return true
        news.visible?(author).should be true
      end
    end

    context 'when no user does not have view permission' do
      it 'returns false' do
        author.stub(:allowed_to?).and_return false
        news.visible?(author).should be false
      end
    end

    context 'when no user is nil' do
      it 'returns false' do
        news.visible?(nil).should be false
      end
    end
  end

  describe '#recipients' do
    it 'returns emails of users to be notified of news' do
      fake_user = mock(:pref => {}, :mail => 'bob@pop.com', :allowed_to? => true)
      project.stub(:notified_users).and_return([fake_user])
      news.recipients.should == ['bob@pop.com']
    end
  end

  describe News, '.latest' do
    let(:news) { News.new(:author => author, :project => project, :title => "title", :description => 'description') }

    it 'returns latest news for projects visible by user' do
      news.save!
      Project.stub(:allowed_to_condition).and_return('')
      News.latest.should == [news]
    end
  end

  describe '#send_mentions' do
    it 'parses mentions in the news object' do
      Mention.should_receive(:parse).with(news, author.id)
      news.send_mentions
    end
  end

  describe '#mention' do
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

end
