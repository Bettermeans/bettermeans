require 'spec_helper'

describe Journal, '#send_mentions' do

  it 'delegates to Mention' do
    journal = Journal.new({:user_id => 5})
    Mention.should_receive(:parse).with(journal, 5)
    journal.send_mentions
  end

end
