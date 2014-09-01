require 'spec_helper'

describe InvitationsController, '#edit' do

  let(:invitation) { Factory.create(:invitation) }
  let(:project) { Factory.create(:project) }
  let(:user) { Factory.create(:user) }
  let(:valid_params) { { :id => invitation.id, :project_id => project.id } }

  before(:each) do
    user.add_as_core(project)
    login_as(user)
  end

  it 'sets @invitation' do
    get(:edit, valid_params)
    assigns(:invitation).should == invitation
  end

end
