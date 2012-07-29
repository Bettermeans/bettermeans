# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class Document < ActiveRecord::Base
  belongs_to :project
  acts_as_attachable :delete_permission => :manage_documents

  acts_as_searchable :columns => ['title', "#{table_name}.description"], :include => :project

  acts_as_event :title => Proc.new {|o| "#{l(:label_document)}: #{o.title}"},
                :author => Proc.new {|o| (a = o.attachments.find(:first, :order => "#{Attachment.table_name}.created_at ASC")) ? a.author : nil },
                :url => Proc.new {|o| {:controller => 'documents', :action => 'show', :id => o.id}}

  validates_presence_of :project, :title
  validates_length_of :title, :maximum => 60

  def size
    sum = 0.0
    attachments.each do |a|
      sum += a.filesize
    end

    sum = sum / 1000000000
    sum.round(3)
  end

  def visible?(user=User.current)
    !user.nil? && user.allowed_to?(:view_documents, project)
  end

  def updated_at
    unless @updated_at
      a = attachments.find(:first, :order => 'created_at DESC')
      @updated_at = (a && a.created_at) || created_at
    end
    @updated_at
  end

  # Returns the mail adresses of users that should be notified
  def recipients
    notified = project.notified_users
    notified.reject! {|user| !visible?(user) || user.pref[:no_emails]}
    notified.collect(&:mail)
  end
end


