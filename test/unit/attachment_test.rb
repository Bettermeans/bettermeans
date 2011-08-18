# encoding: utf-8
#
# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

require File.dirname(__FILE__) + '/../test_helper'

class AttachmentTest < ActiveSupport::TestCase
  fixtures :issues, :users
  
  def setup
  end

  def test_create
    a = Attachment.new(:container => Issue.find(1),
                       :file => uploaded_test_file("testfile.txt", "text/plain"),
                       :author => User.find(1))
    assert a.save
    assert_equal 'testfile.txt', a.filename
    assert_equal 59, a.filesize
    assert_equal 'text/plain', a.content_type
    assert_equal 0, a.downloads
    # assert_equal Digest::MD5.hexdigest(uploaded_test_file("testfile.txt", "text/plain").read), a.digest #BUGBUG Doesn't work with Amazon S3. Not sure why
    assert File.exist?(a.diskfile)
  end
  
  def test_diskfilename
    assert Attachment.disk_filename("test_file.txt") =~ /^\d{12}_test_file.txt$/
    assert_equal 'test_file.txt', Attachment.disk_filename("test_file.txt")[13..-1]
    assert_equal '770c509475505f37c2b8fb6030434d6b.txt', Attachment.disk_filename("test_accentué.txt")[13..-1]
    assert_equal 'f8139524ebb8f32e51976982cd20a85d', Attachment.disk_filename("test_accentué")[13..-1]
    assert_equal 'cbb5b0f30978ba03731d61f9f6d10011', Attachment.disk_filename("test_accentué.ça")[13..-1]
  end
end


# == Schema Information
#
# Table name: attachments
#
#  id             :integer         not null, primary key
#  container_id   :integer         default(0), not null
#  container_type :string(30)      default(""), not null
#  filename       :string(255)     default(""), not null
#  disk_filename  :string(255)     default(""), not null
#  filesize       :integer         default(0), not null
#  content_type   :string(255)     default("")
#  digest         :string(40)      default(""), not null
#  downloads      :integer         default(0), not null
#  author_id      :integer         default(0), not null
#  created_at     :datetime
#  description    :string(255)
#

