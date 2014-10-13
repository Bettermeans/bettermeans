require 'spec_helper'

describe ActivityStreamsController, '#update' do

  let(:admin_user) { Factory.create(:admin_user) }
  let(:activity_stream) { Factory.create(:activity_stream) }
  let(:valid_params) do
    { :id => activity_stream.id, :activity_stream => { :verb => 'wat' } }
  end
  let(:xml_params) { valid_params.merge(:format => 'xml') }

  before(:each) { login_as(admin_user) }

  it 'assigns @activity_stream' do
    put(:update, valid_params)
    assigns(:activity_stream).verb.should == 'wat'
  end

  context 'when the activity stream updates attributes' do
    context 'format html' do
      it 'flashes a success message' do
        flash.stub(:sweep)
        put(:update, valid_params)
        flash[:success].should match(/successfully updated/i)
      end

      it 'redirects to the activity stream show page' do
        put(:update, valid_params)
        response.should redirect_to(assigns(:activity_stream))
      end
    end

    context 'format xml' do
      it 'responds status :ok' do
        put(:update, xml_params)
        response.status.should == '200 OK'
      end
    end
  end

  context 'when the activity stream does not update attributes' do
    before(:each) do
      activity_stream.stub(:valid?).and_return(false)
      activity_stream.errors.add(:wat, 'an error')
      ActivityStream.stub(:find).and_return(activity_stream)
    end

    context 'format html' do
      it 'renders the edit page' do
        put(:update, valid_params)
        response.should render_template('activity_streams/edit')
      end
    end

    context 'format xml' do
      it 'renders the activity stream errors'do
        put(:update, xml_params)
        response.body.should == activity_stream.errors.to_xml
      end

      it 'renders status :unprocessable_entity' do
        put(:update, xml_params)
        response.status.should == '422 Unprocessable Entity'
      end
    end
  end

end
