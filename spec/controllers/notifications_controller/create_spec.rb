require 'spec_helper'

describe NotificationsController, '#create' do

  it 'assigns @notification' do
    post(:create)
    assigns(:notification).should_not be_new_record
  end

  context 'when the notification is valid' do
    it 'flashes a success message' do
      flash.stub(:sweep)
      post(:create)
      flash[:success].should match(/successfully created/i)
    end

    it 'redirects to the notification page' do
      post(:create)
      response.should redirect_to(assigns(:notification))
    end

    it 'responds to xml' do
      post(:create, :format => 'xml')
      response.body.should == assigns(:notification).to_xml
      response.location.should == notification_url(assigns(:notification))
      response.status.should == '201 Created'
    end
  end

  context 'when the notification is invalid' do
    let(:bad_notification) { Factory.build(:notification) }

    before(:each) do
      bad_notification.stub(:valid?).and_return(false)
      bad_notification.errors.add(:wat, 'an error')
      Notification.stub(:new).and_return(bad_notification)
    end

    it 'renders the "new" action' do
      post(:create)
      response.should render_template('notifications/new')
    end

    it 'responds to xml' do
      post(:create, :format => 'xml')
      response.body.should == bad_notification.errors.to_xml
      response.status.should == '422 Unprocessable Entity'
    end
  end

end
