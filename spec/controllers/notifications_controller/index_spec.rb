require 'spec_helper'

describe NotificationsController, '#index' do

  let(:user) { Factory.create(:user) }
  let!(:mention) do
    Factory.create(:notification, :variation => 'mention', :recipient => user)
  end
  let!(:notification) { Factory.create(:notification, :recipient => user) }

  before(:each) { login_as(user) }

  it 'sets @notifications' do
    get(:index)
    assigns(:notifications).should == [notification]
  end

  it 'sets @mentions' do
    get(:index)
    assigns(:mentions).should == [mention]
  end

  it 'responds with html' do
    get(:index)
    response.should render_template('notifications/index')
    response.layout.should == 'layouts/gooey'
  end

  it 'responds with xml' do
    get(:index, :format => 'xml')
    response.body.should == [notification].to_xml
  end

end
