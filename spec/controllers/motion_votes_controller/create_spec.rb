require 'spec_helper'

describe MotionVotesController, '#create' do

  let(:user) { Factory.create(:user) }
  let(:motion) { Factory.create(:motion) }
  let(:valid_params) { { :motion_id => motion.id, :points => 50 } }

  before(:each) { login_as(user) }

  it 'assigns @motion_vote' do
    time = 1.hour.ago
    post(:create, valid_params.merge(:motion_vote => { :created_at => time }))
    assigns(:motion_vote).created_at.should == time
  end

  it 'sets the motion for the motion vote' do
    post(:create, valid_params)
    assigns(:motion_vote).motion.should == motion
  end

  it 'sets the user for the motion vote' do
    post(:create, valid_params)
    assigns(:motion_vote).user.should == user
  end

  context 'when the motion is type "share"' do
    before(:each) do
      motion.update_attributes!(:motion_type => Motion::TYPE_SHARE)
      Factory.create(:share, :project => motion.project, :owner => user, :amount => 2)
    end

    it 'sets the points on the motion vote times the sum of share amounts' do
      post(:create, valid_params)
      assigns(:motion_vote).points.should == 100
    end
  end

  context 'when the motion type is not "share"' do
    it 'sets the points on the motion' do
      post(:create, valid_params)
      assigns(:motion_vote).points.should == 50
    end
  end

  context 'when the motion vote saves' do
    context 'format js' do
      it 'renders "cast_vote"' do
        post(:create, valid_params)
        response.should render_template('motion_votes/cast_vote')
      end
    end
  end

  context 'when the motion does not save' do
    let(:motion_vote) { MotionVote.new }

    before(:each) do
      motion_vote.errors.add(:created_at, 'butts')
      motion_vote.stub(:save).and_return(false)
      MotionVote.stub(:new).and_return(motion_vote)
    end

    context 'format js' do
      it 'renders an error' do
        post(:create, valid_params)
        response.status.should == '422 Unprocessable Entity'
      end
    end

    context 'format html' do
      it 'renders the new action' do
        post(:create, valid_params.merge(:format => 'html'))
        response.should render_template('motion_votes/new')
      end
    end

    context 'format xml' do
      it 'renders the errors from the motion vote' do
        post(:create, valid_params.merge(:format => 'xml'))
        response.body.should == motion_vote.errors.to_xml
      end

      it 'renders 422 status' do
        post(:create, valid_params.merge(:format => 'xml'))
        response.status.should == '422 Unprocessable Entity'
      end
    end
  end

end
