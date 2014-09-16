require 'spec_helper'

describe InvitationsController, '#index' do

  integrate_views

  let!(:invitation) do
    Factory.create(:invitation, :user => user, :project => project)
  end
  let(:user) { Factory.create(:user) }
  let(:project) { Factory.create(:project) }
  let(:params) { { :project_id => project.id } }

  before(:each) do
    login_as(user)
    user.add_as_core(project)
  end

  it 'assigns @all_invites' do
    get(:index, params)
    assigns(:all_invites).items_per_page.should == 30
  end

  it 'assigns @invitations' do
    get(:index, params)
    assigns(:invitations).should == [invitation]
  end

  it 'renders html' do
    get(:index, params)
    response.should render_template('invitations/index')
    response.layout.should == 'layouts/gooey'
  end

  it 'renders html without the layout if the request is ajax' do
    xhr(:get, :index, params)
    response.should render_template('invitations/index')
    response.layout.should be_nil
  end

  it 'renders xml' do
    get(:index, params.merge(:format => 'xml'))
    response.body.should == [invitation].to_xml
  end

  it 'renders json' do
    get(:index, params.merge(:format => 'json'))
    response.body.should == [invitation].to_json
  end

end
