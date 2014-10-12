require 'spec_helper'

describe AdminController, '#projects' do

  let(:admin_user) { Factory.create(:admin_user) }

  before(:each) { login_as(admin_user) }

  context 'when given params[:status]' do
    it 'assigns @status as params[:status] to integer' do
      get(:projects, :status => '52')
      assigns(:status).should == 52
    end
  end

  context 'when there is no params[:status]' do
    it 'assigns @status as 1' do
      get(:projects)
      assigns(:status).should == 1
    end
  end

end
