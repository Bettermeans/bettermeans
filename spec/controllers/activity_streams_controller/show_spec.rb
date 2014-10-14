require 'spec_helper'

describe ActivityStreamsController, '#show' do

  let(:activity_stream) { Factory.create(:activity_stream) }
  let(:valid_params) { { :id => activity_stream.id } }
  let(:admin_user) { Factory.create(:admin_user) }

  before(:each) { login_as(admin_user) }

  it 'assigns @activity_stream' do
    get(:show, valid_params)
    assigns(:activity_stream).should == activity_stream
  end

  it 'renders html' do
    get(:show, valid_params)
    response.should render_template('activity_streams/show')
    response.layout.should == 'layouts/gooey'
  end

  it 'renders xml' do
    get(:show, valid_params.merge(:format => 'xml'))
    response.body.should == activity_stream.to_xml
  end

end
