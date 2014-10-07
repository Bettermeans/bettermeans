require 'spec_helper'

describe EmailUpdatesController, '#new' do

  integrate_views

  let(:user) { Factory.create(:user) }

  before(:each) { login_as(user) }

  context 'format html' do
    it 'renders "email_updates/new' do
      get(:new)
      response.should render_template('email_updates/new')
    end
  end

  context 'format xml' do
    it 'renders a new'  do
      get(:new, :format => 'xml')
      response.body.should == EmailUpdate.new.to_xml
    end
  end

end
