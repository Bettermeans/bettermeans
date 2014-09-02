require 'spec_helper'

describe NotificationsController, '#new' do

  it 'assigns @notification' do
    get(:new)
    assigns(:notification).should be_new_record
  end

  it 'responds with html' do
    get(:new)
    response.should render_template('notifications/new')
    response.layout.should == 'layouts/gooey'
  end

  it 'responds with xml' do
    get(:new, :format => 'xml')
    response.body.should == Notification.new.to_xml
  end

end
