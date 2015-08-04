require 'spec_helper'

describe ApplicationController, '#attach_files' do

  integrate_views(false)

  class AttachFilesSpecController < ApplicationController
    def attach_em
      project = Project.find(params[:id])
      @attached_files = attach_files(project, params[:attachment_data])
    end
  end

  controller_name :attach_files_spec

  let(:user) { Factory.create(:user) }
  let(:project) { Factory.create(:project) }
  let(:file_1) { fixture_file_upload('/blah.txt', 'application/txt') }
  let(:file_2) { fixture_file_upload('/bloo.txt', 'application/txt') }
  let(:empty_file) { fixture_file_upload('/empty.txt', 'application/txt') }
  let(:attachment_data) do
    {
      :foo => { :file => file_1, :description => 'blah file' },
      :bar => { :file => file_2, :description => 'bloo file' },
    }
  end

  let(:valid_params) do
    { :id => project.id, :attachment_data => attachment_data }
  end

  before(:each) do
    login_as(user)
    RedmineS3::Connection.stub(:put)
    RedmineS3::Connection.stub(:publicly_readable!)
  end

  it 'skips when file is not present' do
    expect do
      blank_data = { :blah => { :file => nil } }
      post(:attach_em, valid_params.merge(:attachment_data => blank_data))
    end.to_not change(Attachment, :count)
  end

  it 'skips blank files' do
    expect do
      blank_data = { :blah => { :file => empty_file } }
      post(:attach_em, valid_params.merge(:attachment_data => blank_data))
    end.to_not change(Attachment, :count)
  end

  it 'creates attachments for each attached file' do
    RedmineS3::Connection.should_receive(:put).with(/blah\.txt/, file_1.read)
    file_1.rewind
    RedmineS3::Connection.should_receive(:put).with(/bloo\.txt/, file_2.read)
    file_2.rewind

    expect do
      post(:attach_em, valid_params)
    end.to change(Attachment, :count).by(2)
    attachment_1, attachment_2 = Attachment.find(:all, :order => :description)

    attachment_1.container.should == project
    attachment_1.description.should == 'blah file'
    attachment_1.author.should == user

    attachment_2.container.should == project
    attachment_2.description.should == 'bloo file'
    attachment_2.author.should == user
  end

  it 'strips spaces out of the description' do
    attachment_data = { :foo => { :file => file_1, :description => ' spacy ' } }
    post(:attach_em, valid_params.merge(:attachment_data => attachment_data))
    Attachment.first.description.should == 'spacy'
  end

  it 'flashes an error when there are unsaved attachments' do
    flash.stub(:sweep)
    Attachment.should_receive(:disk_filename).twice.and_return('*' * 256)
    expect do
      post(:attach_em, valid_params)
    end.to_not change(Attachment, :count)
    flash.now[:error].should match(/2 file\(s\) could not be saved/)
  end

  it 'returns the attachments' do
    post(:attach_em, valid_params)
    all_attachments = Attachment.find(:all, :order => :id)
    assigns(:attached_files).sort_by(&:id).should == all_attachments
  end

  it 'fails silently when the passed in attachments are nil' do
    expect do
      post(:attach_em, valid_params.merge(:attachment_data => nil))
    end.to_not change(Attachment, :count)
  end

  it 'fails silently when the passed in attachments are not a hash' do
    expect do
      post(:attach_em, valid_params.merge(:attachment_data => 'foo'))
    end.to_not change(Attachment, :count)
  end

end
