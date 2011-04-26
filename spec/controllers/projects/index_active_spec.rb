require 'spec_helper'                                                                                                                                        

describe ProjectsController,"#index_active" do
  before :each do
    controller.stub(:respond_to)
    controller.params[:offset] = 5
  end
  
  it "finds the 10 most active public workstreams only" do             
    Project.should_receive(:most_active_public).with(10, anything)
    Project.should_not_receive(:latest_public)
        
    controller.index_active
  end
  
  it "returns most active public workstreams (as active_enterprises)" do      
    expected_most_active = "xxx"
    
    Project.should_receive(:most_active_public).with(10, anything).and_return expected_most_active 
    
    controller.index_active
    
    controller.instance_variable_get(:@active_enterprises).should eql expected_most_active
  end
  
  it "uses the offset parameter from query string" do 
    expected_offset = 1337
        
    controller.params[:offset] = expected_offset
        
    Project.should_receive(:most_active_public).with(anything, expected_offset)
        
    controller.index_active  
  end
end