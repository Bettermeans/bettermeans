require 'spec_helper'

describe Comment do
  let(:author) { User.create!(:foreign_key => 'author_id') }

  describe "associations" do
    it { should belong_to(:author) }
    it { should belong_to(:commented) }
  end

  [:commented].each do |attr|
    it { should validate_presence_of(attr) }
  end

  describe 'notifications' do
    with_args = { :sender_id => 10, :recipient_id => 11, :params => { :mention_text => "10 mentioned 11" }}
    let(:comment) { Comment.new }
    let(:notification) { Notification.create(with_args) }

    describe "#mention" do
      it 'creates a notification' do
        # mentioner_id = 10, mentioned_id = 11, mention_text = "10 mentioned 11"
        comment.stub(:mention).and_return notification
      end
      # it 'creates a new notification' do
      #   comment = Comment.new(..some params..)
      #   comment.stub(:send_mentions)
      #   comment.save!
      #   expect {
      #     comment.mention(..params..)
      #   }.to change(Notification, :count).by(1)

      #   # then the same as above
      #   notification = Notification.last
      #   notification.recipient.should == comment.author
      #   # ...and so on, verifying the other attributes on the notification...
      # end
    end

  end

end
