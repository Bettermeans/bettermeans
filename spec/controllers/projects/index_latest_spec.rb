require 'spec_helper'                                                                                                                                        

describe ProjectsController,"#index_latest" do
  before :each do
    login
    @request.env['HTTPS'] = 'on'
    controller.stub(:respond_to) # TODO: pretty lame to have to do this. Hidden collaborators.
    controller.params[:offset] = 5
  end
  
  it "finds the 10 latest public workstreams only" do             
    Project.should_receive(:latest_public).with(10, anything)
    Project.should_not_receive(:most_active_public)
        
    get :index_latest
  end
  
  it "returns latest public workstreams (as latest_enterprises)" do      
    expected_latest_public = "xxx"
    
    Project.should_receive(:latest_public).with(10, anything).and_return expected_latest_public 
    
    get :index_latest
    
    controller.instance_variable_get(:@latest_enterprises).should eql expected_latest_public
  end
  
  it "uses the offset parameter from query string" do 
    expected_offset = 1337
            
    Project.should_receive(:latest_public).with(anything, expected_offset)
        
    get :index_latest, :offset => expected_offset  
  end
end
