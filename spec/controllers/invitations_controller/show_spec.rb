require 'spec_helper'

describe InvitationsController, '#show' do

  let(:invitation) do
    Factory.create(:invitation, :user => user, :project => project)
  end
  let(:user) { Factory.create(:user) }
  let(:project) { Factory.create(:project) }
  let(:params) { { :id => invitation.id, :project_id => project.id } }

  before(:each) do
    user.add_as_core(project)
    login_as(user)
  end

  it 'sets @invitation' do
    get(:show, params)
    assigns(:invitation).should == invitation
  end

  it 'responds to html' do
    get(:show, params)
    response.should render_template('invitations/show')
    response.layout.should == 'layouts/gooey'
  end

  it 'responds to xml' do
    get(:show, params.merge(:format => 'xml'))
    response.body.should == invitation.to_xml
  end

end
