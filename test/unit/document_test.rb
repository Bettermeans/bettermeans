# Redmine - project management software
# Copyright (C) 2006-2008  Shereef Bishay
#

require File.dirname(__FILE__) + '/../test_helper'

class DocumentTest < ActiveSupport::TestCase
  fixtures :projects, :enumerations, :documents

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
end


# == Schema Information
#
# Table name: documents
#
#  id          :integer         not null, primary key
#  project_id  :integer         default(0), not null
#  category_id :integer         default(0), not null
#  title       :string(60)      default(""), not null
#  description :text
#  created_on  :datetime
#

