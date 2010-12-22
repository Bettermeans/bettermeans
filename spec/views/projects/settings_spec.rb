require 'spec_helper'                                                                                                                                        

describe "projects/settings.html.erb" do
  before(:each) do
    @project = Factory.build(:project)
    assigns[:project] = @project
  end
  it "should show move project link when sub workstream" do
    @project.stub(:root?).and_return false
    render
    response.capture(:sidebar).should have_tag('li#move_project_link')
  end
  it "should not show move project link when root workstream" do
    @project.stub(:root?).and_return true
    render
    response.capture(:sidebar).should_not have_tag('li#move_project_link')
  end
   def content_for(name)
      view.instance_variable_get(:@_content_for)[name]
   end
  
end

