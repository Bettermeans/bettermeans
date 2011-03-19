require "spec_helper"

describe Project,"#visible_by" do 
  fake_user = Class.new do
    def initialize(admin = false, memberships = [])
      @admin,@memberships = admin,memberships
    end
    
    def admin?; @admin; end
    def memberships; @memberships end
  end
  
  describe "given user is admin" do 
    it "returns project status filter if user is admin" do 
      result = Project.visible_by fake_user.new true
      result.should eql "projects.status=1"
    end
  
    it "returns project status and publicity filter if user is not supplied" do 
      result = Project.visible_by
      result.should eql "projects.status=1 AND projects.is_public = 't'"
    end
    
    it "returns project status and publicity filter if user supplied as nil" do 
      result = Project.visible_by nil
      result.should eql "projects.status=1 AND projects.is_public = 't'"
    end
  end
  
  describe "given user is not admin and has memberships" do 
    it "returns project status and either public or memberof filter" do 
      membership = Member.new
      membership.project_id = 1337
      
      user = fake_user.new false, [membership]
      
      result = Project.visible_by user
      
      result.should eql "projects.status=1 AND " + 
        "(projects.is_public = 't' or projects.id IN (#{membership.project_id}))"
    end
  end
  
  describe "given user is not admin and has no memberships" do 
    it "returns project status and publicity filter" do
      a_user_that_is_not_admin_and_has_no_memberships = fake_user, false, []
      result = Project.visible_by User.anonymous
      result.should eql "projects.status=1 AND projects.is_public = 't'"
    end
  end
end

describe User.anonymous," user type" do 
    it "has zero memberships" do 
      User.anonymous.memberships.any?.should be_false
    end
    
    it "is not admin" do 
      User.anonymous.admin?.should be_false
    end
  end