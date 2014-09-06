require 'spec_helper'

describe MotionVotesController, '#index' do

  let!(:motion_vote) { Factory.create(:motion_vote) }

  it 'assigns @motion_votes' do
    get(:index)
    assigns(:motion_votes).should == [motion_vote]
  end

  context 'format html' do
    it 'renders the index page' do
      get(:index)
      response.should render_template('motion_votes/index')
      response.layout.should == 'layouts/gooey'
    end
  end

  context 'format xml' do
    it 'renders the motion votes as xml' do
      get(:index, :format => 'xml')
      response.body.should == [motion_vote].to_xml
    end
  end

end
