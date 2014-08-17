require 'spec_helper'

describe Board, '#visible?' do

  let(:board) do
    Board.create!({
      :name => 'test name',
      :description => 'test desc',
      :project_id => 1
    })
  end

  it 'returns true when the user is allowed to view messages on the project' do
    fake_user = double(:allowed_to? => true)
    User.stub(:current).and_return(fake_user)
    board.visible?.should be true
  end

  it 'returns false when the user is not allowed to view messages on the project' do
    fake_user = double(:allowed_to? => false)
    User.stub(:current).and_return(fake_user)
    board.visible?.should be false
  end

end
