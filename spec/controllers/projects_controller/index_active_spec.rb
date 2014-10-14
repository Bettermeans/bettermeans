require 'spec_helper'

describe ProjectsController,"#index_active" do

  let(:user) { Factory.create(:user) }
  let!(:project) { Factory.create(:project) }

  before :each do
    login_as(user)
  end

  it "finds the 10 most active public workstreams only" do
    get(:index_active)
    assigns(:active_enterprises).should == [project]
  end

end
