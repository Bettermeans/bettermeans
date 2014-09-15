require 'spec_helper'

describe ActivityStreamsController, '#new' do

  integrate_views

  let(:admin_user) { Factory.create(:admin_user) }

  before(:each) { login_as(admin_user) }

  it 'assigns @activity_stream' do
    get(:new)
    assigns(:activity_stream).should be_new_record
  end

  it 'responds to html' do
    get(:new)
    response.should render_template('activity_streams/new')
    response.layout.should == 'layouts/gooey'
  end

  it 'responds to xml' do
    get(:new, :format => 'xml')
    response.body.should == ActivityStream.new.to_xml
  end

end
