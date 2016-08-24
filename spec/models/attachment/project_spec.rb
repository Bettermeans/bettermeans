require 'spec_helper'

describe Attachment, '#project' do

  it 'returns the project for its container' do
    project = Project.new
    issue = Issue.new(:project => project)
    attachment = Attachment.new(:container => issue)
    attachment.project.should == project
  end

end
