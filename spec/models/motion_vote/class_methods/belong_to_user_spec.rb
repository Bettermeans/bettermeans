require 'spec_helper'

describe MotionVote, '.belong_to_user' do

  it 'returns motion vote that belongs to the user' do
    user = Factory.create(:user)
    motion_vote = Factory.create(:motion_vote, :user => user)
    MotionVote.belong_to_user(user.id).should == [motion_vote]
  end

end
