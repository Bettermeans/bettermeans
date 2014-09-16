require 'spec_helper'

describe InvitationsController, '#new' do

  integrate_views

  let(:project) { Factory.create(:project) }
  let(:user) { Factory.create(:user) }
  let(:params) { { :project_id => project.id } }

  before(:each) do
    user.add_as_core(project)
    login_as(user)
  end

  it 'renders an error when the project is not root' do
    project_2 = Factory.create(:project)
    project_2.move_to_child_of(project)
    flash.stub(:sweep)
    get(:new, params.merge(:project_id => project_2.id))
    response.status.should == '500 Internal Server Error'
    flash.now[:error].should match(/project is not root/i)
  end

  it 'sets @note' do
    get(:new, params)
    assigns(:note).should == I18n.t(:text_invitation_note_default, { :user => user, :project => project })
  end

  it 'renders html' do
    get(:new, params)
    response.should render_template('invitations/new')
    response.layout.should == 'layouts/gooey'
  end

end
