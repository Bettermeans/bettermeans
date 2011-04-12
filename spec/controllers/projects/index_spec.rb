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
  
  describe "#index" do 
    it "finds the latest public workstreams" do             
      Project.should_receive(:latest_public)
      
      controller.index
    end
    
    it "finds the most active public workstreams for the current user" do 
      Project.should_receive(:most_active_public)
      
      controller.index
    end

    it "returns latest public workstreams (as latest_enterprises)" do      
      expected_latest_public = "xxx"
      
      Project.should_receive(:latest_public).and_return expected_latest_public 
      
      controller.index
      
      controller.instance_variable_get(:@latest_enterprises).should eql expected_latest_public
    end
    
    it "returns most active public workstreams (as active_enterprises)" do 
      expected_most_active_public = "xxx"
        
      Project.should_receive(:most_active_public).and_return expected_most_active_public
      
      controller.index
      
      controller.instance_variable_get(:@active_enterprises).should eql expected_most_active_public
    end
  end
end
