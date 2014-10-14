require 'spec_helper'

describe NotificationsController, '#destroy' do

  let(:notification) { Factory.create(:notification) }
  let(:valid_params) { { :id => notification.id } }

  it 'destroys the notification' do
    delete(:destroy, valid_params)
    Notification.find_by_id(notification.id).should be_nil
  end

  context 'format html' do
    it 'redirects to notifications/index' do
      delete(:destroy, valid_params)
      response.should redirect_to notifications_path
    end
  end

  context 'format xml' do
    it 'renders 200 OK' do
      delete(:destroy, valid_params.merge(:format => 'xml'))
      response.status.should == '200 OK'
    end
  end
end
