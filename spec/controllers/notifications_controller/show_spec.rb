require 'spec_helper'

describe NotificationsController, '#show' do

  let(:notification) { Factory.create(:notification) }
  let(:valid_params) { { :id => notification.id } }

  it 'sets @notification' do
    get(:show, valid_params)
    assigns(:notification).should == notification
  end

  it 'responds with html' do
    get(:show, valid_params)
    response.should render_template('notifications/show')
    response.layout.should == 'layouts/gooey'
  end

  it 'responds with xml' do
    get(:show, valid_params.merge(:format => 'xml'))
    response.body.should == notification.to_xml
  end

end
