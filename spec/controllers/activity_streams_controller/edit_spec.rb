require 'spec_helper'

describe ActivityStreamsController, '#edit' do

  let(:activity_stream) { Factory.create(:activity_stream) }
  let(:admin_user) { Factory.create(:user, :admin => true) }

  before(:each) { login_as(admin_user) }

  it 'assigns @activity_stream' do
    get(:edit, :id => activity_stream.id)
    assigns(:activity_stream).should == activity_stream
  end

end
