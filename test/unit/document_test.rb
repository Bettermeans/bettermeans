# Redmine - project management software
# Copyright (C) 2006-2011  See readme for details and license
#

require File.dirname(__FILE__) + '/../test_helper'

class DocumentTest < ActiveSupport::TestCase
  fixtures :projects, :enumerations, :documents, :attachments

  def test_create
    doc = Document.new(:project => Project.find(1), :title => 'New document', :category => Enumeration.find_by_name('User documentation'))
    assert doc.save
  end

  def test_create_should_send_email_notification
    ActionMailer::Base.deliveries.clear
    Setting.notified_events << 'document_added'
    doc = Document.new(:project => Project.find(1), :title => 'New document', :category => Enumeration.find_by_name('User documentation'))

    assert doc.save
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  def test_create_with_default_category
    # Sets a default category
    e = Enumeration.find_by_name('Technical documentation')
    e.update_attributes(:is_default => true)

    doc = Document.new(:project => Project.find(1), :title => 'New document')
    assert_equal e, doc.category
    assert doc.save
  end

  def test_updated_at_with_attachments
    d = Document.find(1)
    assert d.attachments.any?
    assert_equal d.attachments.map(&:created_at).max, d.updated_at
  end

  def test_updated_at_without_attachments
    d = Document.find(2)
    assert d.attachments.empty?
    assert_equal d.created_at, d.updated_at
  end
end



# == Schema Information
#
# Table name: documents
#
#  id          :integer         not null, primary key
#  project_id  :integer         default(0), not null
#  title       :string(60)      default(""), not null
#  description :text
#  created_at  :datetime
#

