require 'spec_helper'

describe MotionVotesController, '#edit' do

  integrate_views

  let(:motion_vote) { Factory.create(:motion_vote) }
  let(:valid_params) { { :id => motion_vote.id } }

  it 'assigns @motion_vote' do
    get(:edit, valid_params)
    assigns(:motion_vote).should == motion_vote
  end

end
