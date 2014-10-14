require 'spec_helper'

describe MotionVotesController, '#new' do

  it 'assigns @motion_vote' do
    get(:new)
    assigns(:motion_vote).should be_new_record
  end

  context 'format html' do
    it 'renders the new template' do
      get(:new)
      response.should render_template('motion_votes/new')
      response.layout.should == 'layouts/gooey'
    end
  end

  context 'format xml' do
    it 'renders a new motion vote as xml' do
      get(:new, :format => 'xml')
      response.body.should == MotionVote.new.to_xml
    end
  end

end
