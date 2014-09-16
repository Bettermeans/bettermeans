require 'spec_helper'

describe MotionVotesController, '#destroy' do

  integrate_views

  let(:motion_vote) { Factory.create(:motion_vote) }
  let(:valid_params) { { :id => motion_vote.id } }

  it 'deletes the motion vote' do
    delete(:destroy, valid_params)
    MotionVote.find_by_id(motion_vote.id).should be_nil
  end

  context 'format html' do
    it 'redirects to motion_votes/index' do
      delete(:destroy, valid_params)
      response.should redirect_to(motion_votes_path)
    end
  end

  context 'format xml' do
    it 'renders status 200' do
      delete(:destroy, valid_params.merge(:format => 'xml'))
      response.status.should == '200 OK'
    end
  end

end
