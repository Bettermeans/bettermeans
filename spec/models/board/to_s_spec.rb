require 'spec_helper'

describe Board, '#to_s' do

  let(:board) do
    Board.create!({
      :name => 'test name',
      :description => 'test desc',
      :project_id => 1
    })
  end

  it "returns the board name" do
    board.to_s.should == 'test name'
  end

end
