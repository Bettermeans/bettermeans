require 'spec_helper'

describe ActivityStreamsController, '#create' do

  let(:admin_user) { Factory.create(:admin_user) }
  let(:valid_params) { { :activity_stream => { :verb => 'wat' } } }
  let(:xml_params) { valid_params.merge(:format => 'xml') }

  before(:each) { login_as(admin_user) }

  it 'assigns @activity_stream' do
    post(:create, valid_params)
    assigns(:activity_stream).verb.should == 'wat'
  end

  context 'if the activity stream saves' do
    it 'flashes a success message' do
      flash.stub(:sweep)
      post(:create, valid_params)
      flash[:success].should match(/successfully created/i)
    end

    context 'format html' do
      it 'redirects to the activity stream' do
        post(:create, valid_params)
        response.should redirect_to(assigns(:activity_stream))
      end
    end

    context 'format xml' do
      it 'renders the activity stream' do
        post(:create, xml_params)
        response.body.should == assigns(:activity_stream).to_xml
      end

      it 'returns http status :created' do
        post(:create, xml_params)
        response.status.should == '201 Created'
      end

      it 'returns the location of the activity_stream' do
        post(:create, xml_params)
        expected_location = activity_stream_url(assigns(:activity_stream))
        response.location.should == expected_location
      end
    end
  end

  context 'if the activity stream does not save' do
    let(:bad_stream) { ActivityStream.new(valid_params[:activity_stream]) }

    before(:each) do
      bad_stream.should_receive(:save).and_return(false)
      bad_stream.stub(:errors).and_return([{ :wat => 'an error' }])
      ActivityStream.should_receive(:new).and_return(bad_stream)
    end

    context 'format html' do
      it 'renders the new action' do
        post(:create, valid_params)
        response.should render_template('activity_streams/new')
      end
    end

    context 'format xml' do
      it 'renders the activity stream errors' do
        post(:create, xml_params)
        response.body.should == [{ :wat => 'an error' }].to_xml
      end

      it 'returns http status :unprocessable_entity' do
        post(:create, xml_params)
        response.status.should == '422 Unprocessable Entity'
      end
    end
  end

end
