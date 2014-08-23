require 'spec_helper'

describe News, '#send_mentions' do

  let(:author) { Factory.create(:user) }
  let(:project) { Factory.create(:project) }
  let(:news) { News.new(:author => author, :project => project) }

  it 'parses mentions in the news object' do
    Mention.should_receive(:parse).with(news, author.id)
    news.send_mentions
  end

end
