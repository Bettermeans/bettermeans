require 'spec_helper'

describe MotionVotesController, '#show' do

  let(:motion_vote) { Factory.create(:motion_vote) }
  let(:valid_params) { { :id => motion_vote.id } }

  it 'assigns @motion_vote' do
    get(:show, valid_params)
    assigns(:motion_vote).should == motion_vote
  end

  context 'format html' do
    it 'renders the show template' do
      get(:show, valid_params)
      response.should render_template('motion_votes/show')
      response.layout.should == 'layouts/gooey'
    end
  end

  context 'format xml' do
    it 'renders the motion vote as xml' do
      get(:show, valid_params.merge(:format => 'xml'))
      response.body.should == motion_vote.to_xml
    end
  end

end
