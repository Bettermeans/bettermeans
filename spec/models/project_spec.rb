require "spec_helper"

describe Project,"#visible_by" do 
  fake_user = Class.new do 
    def admin?; true; end
  end
  
  it "returns project status filter if user is admin" do 
    result = Project.visible_by fake_user.new
    result.should eql "projects.status=1"
  end
  
  it "returns project status and publicity filter if user is not supplied" do 
    result = Project.visible_by
    result.should eql "projects.status=1 AND projects.is_public = 't'"
  end
end