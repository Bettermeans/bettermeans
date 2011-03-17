require "spec_helper"

describe Project,"#visible_by" do 
  fake_user = Class.new do 
    def admin?; true; end
  end
  
  it "returns project status filter if user is admin" do 
    result = Project.visible_by fake_user.new
    result.should eql "projects.status=1"
  end
end