require 'spec_helper'

describe MotionVotesController, '#update' do

  let(:motion_vote) { Factory.create(:motion_vote) }
  let(:valid_params) do
    { :id => motion_vote.id, :motion_vote => { :points => 32 } }
  end
  let(:xml_params) { valid_params.merge(:format => 'xml') }

  it 'assigns @motion_vote' do
    put(:update, valid_params)
    assigns(:motion_vote).should == motion_vote
    assigns(:motion_vote).points.should == 32
  end

  context 'when the motion vote updates' do
    context 'format html' do
      it 'flashes a success message' do
        flash.stub(:sweep)
        put(:update, valid_params)
        flash[:success].should match(/successfully updated/i)
      end

      it 'redirects to motion votes show' do
        put(:update, valid_params)
        response.should redirect_to(motion_vote)
      end
    end

    context 'format xml' do
      it 'renders status 200' do
        put(:update, xml_params)
        response.status.should == '200 OK'
      end
    end
  end

  context 'when the motion vote does not update' do
    before(:each) do
      motion_vote.errors.add(:wat, 'an error')
      motion_vote.stub(:save).and_return(false)
      MotionVote.stub(:find).and_return(motion_vote)
    end

    context 'format html' do
      it 'renders the edit action' do
        put(:update, valid_params)
        response.should render_template('motion_votes/edit')
      end
    end

    context 'format xml' do
      it 'renders the errors from the motion vote' do
        put(:update, xml_params)
        response.body.should == motion_vote.errors.to_xml
      end

      it 'renders error status' do
        put(:update, xml_params)
        response.status.should == '422 Unprocessable Entity'
      end
    end
  end

end
