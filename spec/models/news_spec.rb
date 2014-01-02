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
        news.visible?(author).should be_true
      end
    end

    context 'when no user does not have view permission' do
      it 'returns false' do
        author.stub(:allowed_to?).and_return false
        news.visible?(author).should be_false
      end
    end

    context 'when no user is nil' do
      it 'returns false' do
        news.visible?(user=nil).should be_false
      end
    end
  end

  describe '#recipients' do
    # this test passes, but because the record is empty - best way to create sample record?
    xit 'returns emails of users to be notified of news' do
      notified = project.notified_users
      news.recipients.should == notified.collect(&:mail)
    end
  end

  describe News, '.latest' do
    xit 'returns latest news for projects visible by user' do
      News.latest
    end
  end

  describe '#send_mentions' do
    it 'should return a hash of comment by author' do
      Mention.should_receive(:parse).with(news, author.id)
      news.send_mentions
    end
  end

  describe '#mention' do
    news_args = { :sender_id => 10,
                  :recipient_id => 11,
                  :params => {:mention_text => "10 mentioned 11"} }

    let(:notification) { Notification.create(news_args) }

    it 'creates a new notification' do
      expect {
          news.mention(news_args[:sender_id], news_args[:recipient_id], news_args[:params])
        }.to change(Notification, :count).by(1)
    end

    it 'sends noitification from the correct sender' do
      news.mention(news_args[:sender_id],
                   news_args[:recipient_id],
                   news_args[:params])
      Notification.last.sender_id.should == news_args[:sender_id]
    end

    it 'sends notification to the correct recipient' do
      news.mention(news_args[:sender_id],
                   news_args[:recipient_id],
                   news_args[:params])
      Notification.last.recipient_id.should == news_args[:recipient_id]
    end
  end

end
