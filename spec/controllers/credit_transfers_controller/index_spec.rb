require 'spec_helper'

describe CreditTransfersController, '#index' do

  integrate_views

  let(:user) { Factory.create(:admin_user) }
  let(:project1) { Factory.create(:project) }
  let(:project2) { Factory.create(:project) }
  let(:project3) { Factory.create(:project) }
  let(:credit1) { Factory.create(:credit, :owner => user) }
  let(:credit2) { Factory.create(:credit, :owner => user) }
  let(:credit3) { Factory.create(:credit) }

  before(:each) do
    login_as(user)
  end

  it 'sets the project list' do
    credit1.update_attributes!(:project => project1)
    credit2.update_attributes!(:project => project2)
    credit3.update_attributes!(:project => project3)
    get(:index)
    assigns(:project_list).should == [project1, project2]
  end

end
