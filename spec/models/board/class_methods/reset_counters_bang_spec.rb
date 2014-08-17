require 'spec_helper'

describe Board, '.reset_counters!' do

  let(:board) do
    Board.create!({
      :name => 'test name',
      :description => 'test desc',
      :project_id => 1
    })
  end

  it "updates topics_count and message_count" do
    Message.create!({:board_id => board.id,
      :subject => 'text',
      :content => 'text'
    })
    Message.create!({
      :board_id => board.id,
      :subject => 'text',
      :content => 'text',
      :parent_id => 1
    })
    Board.reset_counters!(board.id)
    board.reload.topics_count.should == 1
    board.messages_count.should == 2
  end

  it "updates last_message_id" do
    message = Message.create!({
      :board_id => board.id,
      :subject => 'text',
      :content => 'text',
      :parent_id => 1,
    })
    Board.reset_counters!(board.id)
    board.reload.last_message_id.should == message.id
  end

end
