require 'spec_helper'

describe NotificationsController, '#edit' do

  let(:notification) { Factory.create(:notification) }
  let(:valid_params) { { :id => notification.id } }

  it 'sets @notification' do
    get(:edit, valid_params)
    assigns(:notification).should == notification
  end

end
