require 'spec_helper'

describe NotificationsController, '#hide' do

  integrate_views

  let(:notification) { Factory.create(:notification) }
  let(:valid_params) { { :notification_id => notification.id } }

  it 'assigns @notification' do
    put(:hide, valid_params)
    assigns(:notification).should == notification
  end

  context 'when notification is successfully marked as responded' do
    it 'responds to js' do
      put(:hide, valid_params.merge(:format => 'js'))
      response.should render_template('notifications/hide')
    end

    it 'responds to xml' do
      put(:hide, valid_params.merge(:format => 'xml'))
      response.status.should == '200 OK'
    end
  end

  context 'when notification is not successfully marked as responded' do
    let(:fake_errors) { [{ :my => 'an error' }] }

    before(:each) do
      bad_notification = double(:mark_as_responded => false, :errors => fake_errors)
      Notification.stub(:find).and_return(bad_notification)
    end

    it 'flashes a success message' do
      flash.stub(:sweep)
      put(:hide, valid_params)
      flash[:success].should == 'Error ignoring notification'
    end

    it 'responds to js' do
      put(:hide, valid_params.merge(:format => 'js'))
      response.should render_template('notifications/error')
    end

    it 'responds to xml' do
      put(:hide, valid_params.merge(:format => 'xml'))
      response.body.should == fake_errors.to_xml
      response.status.should == '422 Unprocessable Entity'
    end
  end

end
