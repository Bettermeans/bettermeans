require 'spec_helper'

describe Comment do

  let(:author) { Factory.create(:user) }
  let(:comment) { Comment.new(:author => author) }

  describe "associations" do
    it { should belong_to(:author) }
    it { should belong_to(:commented) }
  end

  describe 'validations' do
    it { should validate_presence_of(:commented) }
  end

  describe '#send_mentions' do
    it 'should send mention of itself' do
      Mention.should_receive(:parse).with(comment, author.id)
      comment.send_mentions
    end
  end

  describe '#title' do
    context "When commented type is 'News'" do
      let(:news) {
        News.create!( :title => "Rob is cool",
                      :description => "Comment by dklounge")
      }

      it 'returns the title of the news item' do
        comment.commented = news
        comment.commented.title.should == "Rob is cool"
      end
    end
  end

  describe "#mention" do
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

end
