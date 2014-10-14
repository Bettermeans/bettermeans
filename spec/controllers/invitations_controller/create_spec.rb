require 'spec_helper'

describe InvitationsController, '#create' do

  let(:user) { Factory.create(:user) }
  let(:project) { Factory.create(:project) }
  let(:invitation_params) do
    { :role_id => Role.contributor.id.to_s }
  end
  let(:valid_params) do
    {
      :project_id => project.id,
      :invitation => invitation_params,
      :emails => 'a@a.com',
    }
  end

  before(:each) do
    user.add_as_core(project)
    login_as(user)
  end

  it 'sets @email_array' do
    post(:create, valid_params)
    assigns(:email_array).should == ['a@a.com']
  end

  it 'sets @invitation' do
    post(:create, valid_params)
    assigns(:invitation).mail.should == 'a@a.com'
    assigns(:invitation).project.should == project
    assigns(:invitation).user.should == user
  end

  context 'when invitations are successully created' do
    it 'sets @emails to nil' do
      post(:create, valid_params)
      assigns(:emails).should be_nil
    end

    it 'sets @note' do
      post(:create, valid_params.merge(:note => 'foo'))
      assigns(:note).should == 'foo'
    end

    it 'sets @roles' do
      post(:create, valid_params)
      assigns(:roles).sort.should == Role.find_all_by_level(1).sort
    end

    it 'flashes a success message' do
      flash.stub(:sweep)
      post(:create, valid_params)
      flash[:success].should match(/invitation.*success/i)
    end

    it 'renders the "new" template' do
      post(:create, valid_params)
      response.should render_template('invitations/new')
      response.layout.should == 'layouts/gooey'
    end
  end

  context 'when no invitations are successfully created' do
    let(:invalid_params) { valid_params.merge(:emails => 'what what') }

    it 'sets @emails' do
      post(:create, invalid_params)
      assigns(:emails).should == 'what what'
    end

    it 'flashes an error message' do
      flash.stub(:sweep)
      post(:create, invalid_params)
      flash[:error].should match(/failed to send/i)
    end

    it 'renders the "new" template' do
      post(:create, invalid_params)
      response.should render_template('invitations/new')
      response.layout.should == 'layouts/gooey'
    end
  end

end
