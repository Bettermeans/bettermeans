require 'spec_helper'

describe ActivityStreamsController, '#destroy' do

  let(:admin_user) { Factory.create(:admin_user) }
  let(:activity_stream) { Factory.create(:activity_stream) }
  let(:valid_params) { { :id => activity_stream.id } }
  let(:xml_params) { valid_params.merge(:format => 'xml') }

  before(:each) { login_as(admin_user) }

  context 'when the activity stream soft destroys' do
    it 'updates the activity stream to status deleted' do
      delete(:destroy, valid_params)
      activity_stream.reload.status.should == ActivityStream::DELETED
    end

    context 'format html' do
      it 'flashes a success message' do
        flash.stub(:sweep)
        delete(:destroy, valid_params)
        flash[:success].should match(/activity removed/i)
      end

      it 'redirects back to the reference page' do
        delete(:destroy, valid_params.merge(:ref => '/projects'))
        response.should redirect_to(projects_url)
      end
    end

    context 'format xml' do
      it 'renders status 200' do
        delete(:destroy, xml_params)
        response.status.should == '200 OK'
      end
    end
  end

  context 'when the activity stream does not soft destroy' do
    before(:each) do
      activity_stream.stub(:soft_destroy).and_return(false)
      ActivityStream.stub(:find).and_return(activity_stream)
    end

    context 'format html' do
      it 'flashes an error message' do
        flash.stub(:sweep)
        delete(:destroy, valid_params)
        flash[:error].should match(/error removing/i)
      end

      it 'redirects back to the ref page' do
        delete(:destroy, valid_params.merge(:ref => '/projects'))
        response.should redirect_to(projects_url)
      end
    end

    context 'format xml' do
      it 'renders status 400' do
        delete(:destroy, xml_params)
        response.status.should == '422 Unprocessable Entity'
      end
    end
  end

end
