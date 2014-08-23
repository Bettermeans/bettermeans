require 'spec_helper'

describe Comment, '#send_mentions' do

  let(:author) { Factory.create(:user) }
  let(:comment) { Comment.new(:author => author) }

  it 'should send mention of itself' do
    Mention.should_receive(:parse).with(comment, author.id)
    comment.send_mentions
  end

end
