require 'spec_helper'

describe Board, '#to_s' do

  let(:board) { Board.new(:name => 'test name') }

  it "returns the board name" do
    board.to_s.should == 'test name'
  end

end
