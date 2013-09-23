require 'spec_helper'

describe Board do
  let(:board) do
    Board.create!(
      {:name => 'test name',
       :description => 'test desc',
       :project_id => 1
      }
    )
  end

  let(:user) { User.new }

  describe "#visible?" do
    it "returns true if the user is allowed to view messages on the project" do
      fake_user = double(:allowed_to? => true)
      User.stub(:current).and_return(fake_user)
      board.should be_visible
    end

    it "returns false if the user is not allowed to view messages on the project" do
      fake_user = double(:allowed_to? => false)
      User.stub(:current).and_return(fake_user)
      board.should_not be_visible
    end
  end

  describe "#to_s" do
    it "returns the board name" do
      board.to_s.should == 'test name'
    end
  end

  describe "#reset_counters!" do
    it "calls .reset_counters!" do
      Board.should_receive(:reset_counters!).with(board.id)
      board.reset_counters!
    end
  end

  describe ".reset_counters!" do
    it "updates topics_count and message_count" do
      Message.create!({:board_id => board.id, :subject => 'text', :content => 'text'})
      Message.create!({:board_id => board.id, :subject => 'text', :content => 'text', :parent_id => 1})
      Board.reset_counters!(board.id)
      board.reload.topics_count.should == 1
      board.messages_count.should == 2
    end

    it "updates last_message_id" do
      message = Message.create!({:board_id => board.id,
                                 :subject => 'text',
                                 :content => 'text',
                                 :parent_id => 1})
      Board.reset_counters!(board.id)
      board.reload.last_message_id.should == message.id
    end
  end
end
