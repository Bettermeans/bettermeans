require 'spec_helper'                                                                                                                                        

describe ProjectsController do
  before(:each) do
    login
    User.stub_chain(:current, :allowed_to?).and_return true
    @root = Factory.create(:project, :name => 'root')
    @parent = Factory.create(:project, :name => 'parent')
    @project = Factory.create(:project, :name => 'project')
    @parent.set_parent!(@root)
    @project.set_parent!(@parent)
  end

  describe "#move" do
    it "should redirect if project has no parent" do
      get :move, :id => @root.id
      response.should be_redirect
    end

    it "should deny access if user not authorized" do
      User.stub_chain(:current, :allowed_to?).and_return false
      controller.should_receive(:deny_access)
      get :move, :id => @project.id
    end

    describe "(GET)" do
      it "should render move template" do
        get :move, :id => @project.id
        response.should render_template('projects/move.html.erb')
      end

      it "should not show children or self in allowed parents" do
        get :move, :id => @parent.id
        assigns(:allowed_projects).should include(@root)
        assigns(:allowed_projects).should_not include(@parent)
        assigns(:allowed_projects).should_not include(@project)
      end
    end

    describe "(POST)" do
      describe "with valid parent" do
        it "should update projects parent_id" do
          post :move, :id => @project.id, :parent_id => @root.id
          @project.reload.parent_id.should == @root.id
        end
        it "should redirect to project page" do
          post :move, :id => @project.id, :parent_id => @root.id
          response.should be_redirect
        end
        it "should create an activity stream" do
          lambda {
            post :move, :id => @project.id, :parent_id => @root.id
          }.should change {ActivityStream.count}
        end
      end
      describe "with invalid parent" do
        it "should render 403" do
          @new_project = Factory.create(:project)
          post :move, :id => @project.id, :parent_id => @new_project
          response.should render_template('common/403')
        end
      end
    end
  end
end
