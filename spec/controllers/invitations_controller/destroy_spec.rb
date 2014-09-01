require 'spec_helper'

describe InvitationsController, '#destroy' do

  let(:invitation) { Factory.create(:invitation) }
  let(:user) { Factory.create(:user) }
  let(:project) { Factory.create(:project) }
  let(:valid_params) { { :id => invitation.id, :project_id => project.id } }

  before(:each) do
    user.add_as_core(project)
    login_as(user)
  end

  it 'destroys the invitation' do
    delete(:destroy, valid_params)
    Invitation.find_by_id(invitation.id).should be_nil
  end

  it 'renders success javascript' do
    delete(:destroy, valid_params)
    response.body.should include('highlight')
    response.body.should include("row-#{invitation.id}")
    response.body.should include('3000')
    response.body.should include('remove')
    response.body.should include(I18n.t(:notice_successful_delete))
  end

end
