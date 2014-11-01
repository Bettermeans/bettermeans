require 'spec_helper'

describe MotionsController, '#show' do

  let(:motion) { Factory.create(:motion) }
  let(:project) { Factory.create(:project) }
  let(:user) { Factory.create(:user) }
  let(:valid_params) { { :id => motion.id, :project_id => project.id } }

  before(:each) { login_as(user) }

  context 'when the current user is the concerned user' do
    it 'renders a 404 message' do
      motion.update_attributes!(:concerned_user => user)
      get(:show, valid_params)
      response.status.should == '403 Forbidden'
    end
  end

  context 'when the motion does not have a topic' do
    it 'creates a topic for the motion' do
      motion.update_attributes!(:topic => nil)
      get(:show, valid_params)
      motion.reload.topic.should_not be_nil
    end
  end

  it 'assigns @topic' do
    get(:show, valid_params)
    assigns(:topic).should == motion.topic
  end

  it 'assigns @board' do
    get(:show, valid_params)
    assigns(:board).should == motion.topic.board
  end

  it 'assigns @replies' do
    message_1 = Factory.create(:message, :parent => motion.topic)
    message_2 = Factory.create(:message, :parent => motion.topic)
    get(:show, valid_params)
    assigns(:replies).should == [message_1, message_2]
  end

  context 'when current user wants comments in reverse order' do
    it 'assigns @replies in reverse order' do
      user.pref[:comments_sorting] = 'desc'
      user.pref.save!
      message_1 = Factory.create(:message, :parent => motion.topic)
      message_2 = Factory.create(:message, :parent => motion.topic)
      get(:show, valid_params)
      assigns(:replies).should == [message_2, message_1]
    end
  end

  it 'assigns @reply' do
    motion.topic.update_attributes!(:subject => 'blah')
    get(:show, valid_params)
    reply = assigns(:reply)
    reply.subject.should == 'RE: blah'
    reply.should be_new_record
  end

  context 'format html' do
    it 'renders motions/show' do
      get(:show, valid_params)
      response.should render_template('motions/show')
    end
  end

  context 'format xml' do
    it 'renders the motion as xml' do
      get(:show, valid_params.merge(:format => 'xml'))
      response.body.should == motion.reload.to_xml
    end
  end

end
