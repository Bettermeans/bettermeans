require 'spec_helper'                                                                                                                                        

describe ProjectsController,"#new_dash_data" do
  before :each do
    login
    
    controller.stub(:respond_to)
    controller.params[:offset] = 5
    
    Issue.stub(:find).and_return []
    
    @project = Project.new
    @project.stub :locked?
    given_project_has_issue_count 0
        
    Project.stub(:find).and_return @project
    
    @when_william_married_kate = Time.utc 2011,"apr",29,10,00
  end
  
  context "given we are not including sub workstreams" do
    it "sets the project's last_item_updated_on to now and then saves it if it does not have one" do
      given_the_time_now_is @when_william_married_kate    
      given_the_project_last_had_an_item_updated_at nil
    
      @project.should_receive(:save).once
        
      get :new_dashdata
    
      @project.last_item_updated_on.should eql @when_william_married_kate
    end
  end
  
  context "given we are including sub workstreams" do
    it "sets the project's last_item_sub_updated_on to DateTime.now and then saves it if it does not have one" do
      given_the_time_now_is @when_william_married_kate    
    
      @project.last_item_updated_on = @when_william_married_kate
      @project.last_item_sub_updated_on = nil
      @project.stub(:sub_project_array_visible_to).and_return []
      @project.should_receive(:save).once
    
      get :new_dashdata, :include_subworkstreams => true
    
      @project.last_item_sub_updated_on.should eql @when_william_married_kate
    end
  end
  
  it "does not find issues when the last modification was too long ago" do
    two_hours_before_the_wedding = @when_william_married_kate - 2.hours
    
    given_project_has_issue_count issue_count=10
    given_the_time_now_is @when_william_married_kate
    given_the_project_last_had_an_item_updated_at two_hours_before_the_wedding
    
    Issue.should_not_receive :find
        
    get :new_dashdata, :seconds => 1, :issuecount => issue_count
  end
  
  it "does not find issues when the last modification is equal to range" do 
    one_second_before_the_wedding = @when_william_married_kate - 1.seconds
    
    given_project_has_issue_count issue_count=10
    given_the_time_now_is @when_william_married_kate
    given_the_project_last_had_an_item_updated_at one_second_before_the_wedding
    
    Issue.should_not_receive(:find)
        
    get :new_dashdata, :seconds => 1, :issuecount => issue_count
  end
  
  it "does not find issues when the last modification is within the range" do 
    one_second_before_the_wedding = @when_william_married_kate - 1.seconds
    
    given_project_has_issue_count issue_count=10
    given_the_time_now_is @when_william_married_kate
    given_the_project_last_had_an_item_updated_at one_second_before_the_wedding
    
    Issue.should_receive(:find).once
        
    get :new_dashdata, :seconds => 2, :issuecount => issue_count
  end
  
  private
  
  def given_the_project_last_had_an_item_updated_at(_when)
    @project.last_item_updated_on = _when 
  end

  def given_the_time_now_is(what); DateTime.stub(:now).and_return what; end
  def given_project_has_issue_count(how_many)
    @project.stub(:issue_count).and_return(how_many)     
  end
  
  it "returns empty array if no items have changed within the requested number of seconds"
  it "checks sub workstreams if the :include_subworkstreams parameter is supplied"
  it "does what if the project has no items at all"
end