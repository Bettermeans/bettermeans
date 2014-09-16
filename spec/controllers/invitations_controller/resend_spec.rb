require 'spec_helper'

describe InvitationsController, '#resend' do

  integrate_views

  let(:invitation) { Factory.create(:invitation) }
  let(:user) { Factory.create(:user) }
  let(:project) { Factory.create(:project) }
  let(:valid_params) do
    { :id => invitation.id, :note => 'some note', :project_id => project.id }
  end

  before(:each) do
    user.add_as_core(project)
    login_as(user)
  end

  context 'when the invitation resends successfully' do
    it 'renders success javascript' do
      get(:resend, valid_params)
      response.body.should include('highlight')
      response.body.should include("row-#{invitation.id}")
      response.body.should include('3000')
      response.body.should include("resend-#{invitation.id}")
      response.body.should include('Resent!')
      response.body.should include(I18n.t(:notice_successful_update))
    end

    it 'sends a reminder message' do
      mail_params = [:deliver_invitation_remind, invitation, 'some note']
      Mailer.should_receive(:send_later).with(*mail_params)
      get(:resend, valid_params)
    end
  end

  context 'when the invitation fails to resend' do
    it 'renders fail javascript' do
      invitation.update_attributes!(:status => Invitation::ACCEPTED)
      get(:resend, valid_params)
      response.body.should include(I18n.t(:error_general))
    end
  end

end
