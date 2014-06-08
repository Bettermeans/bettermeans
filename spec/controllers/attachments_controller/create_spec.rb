require 'spec_helper'

describe AttachmentsController, '#create' do

  let(:file) { fixture_file_upload('/blah.txt', 'application/txt') }
  let(:project) { Factory.create(:project) }

  before(:each) do
    RedmineS3::Connection.stub(:put)
    RedmineS3::Connection.stub(:publicly_readable!)
  end

  it 'creates an attachment' do
    lambda {
      post(:create, :file => file, :container_id => project.id, :container_type => 'Project')
    }.should change(Attachment, :count).by(1)
    attachment = Attachment.last
    attachment.container.should == project
    attachment.filename.should == 'blah.txt'
    attachment.author.should == User.anonymous
  end

end
