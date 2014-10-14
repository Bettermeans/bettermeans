require 'spec_helper'

describe ProjectsController,"#index_latest" do

  let(:user) { Factory.create(:user) }
  let!(:project) { Factory.create(:project) }

  before :each do
    login_as(user)
  end

  it "finds the 10 latest public projects only" do
    get(:index_latest)
    assigns(:latest_enterprises).should == [project]
  end

end
