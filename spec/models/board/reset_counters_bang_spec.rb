require 'spec_helper'

describe Board, '#reset_counters!' do

  let(:board) do
    Board.create!({
      :name => 'test name',
      :description => 'test desc',
      :project_id => 1
    })
  end

  it "calls .reset_counters!" do
    Board.should_receive(:reset_counters!).with(board.id)
    board.reset_counters!
  end

end
